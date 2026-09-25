import AppKit
import Combine
import CryptoKit
import Security
import SwiftUI

// VibePollo's Web UI API is separate from the GameStream connection. Keep its
// credentials out of preferences, logs, and Moonlight's stream configuration.
@objc final class HostStatsWindowFactory: NSObject {
  @objc static func makeWindow() -> NSWindowController {
    let controller = NSHostingController(rootView: HostStatsView().modifier(AppAppearance()))
    let window = NSWindow(contentViewController: controller)
    window.title = "VibePollo Host Stats"
    window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
    window.setContentSize(NSSize(width: 610, height: 540))
    window.minSize = NSSize(width: 490, height: 400)
    window.center()
    window.isReleasedWhenClosed = false
    return NSWindowController(window: window)
  }
}

private enum HostStatsKeychain {
  private static let service = "Moonlight.VibePollo.HostStats"

  static func read(for host: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: host,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var result: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
          let bytes = result as? Data else { return nil }
    return String(data: bytes, encoding: .utf8)
  }

  static func save(_ token: String, for host: String) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: host,
    ]
    let data = Data(token.utf8)
    let update = SecItemUpdate(query as CFDictionary,
                               [kSecValueData as String: data] as CFDictionary)
    if update == errSecSuccess { return true }
    guard update == errSecItemNotFound else { return false }
    var add = query
    add[kSecValueData as String] = data
    return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
  }
}

private struct HostSample: Decodable {
  let cpu_percent: Double?
  let cpu_temp_c: Double?
  let gpu_percent: Double?
  let gpu_encoder_percent: Double?
  let gpu_temp_c: Double?
  let ram_used_bytes: Double?
  let ram_total_bytes: Double?
  let vram_used_bytes: Double?
  let vram_total_bytes: Double?
  let net_rx_bps: Double?
  let net_tx_bps: Double?
}

private struct StreamSample {
  let hostUUID: String
  let hostName: String
  let hostAddress: String
  let fps: Double
  let networkLoss: Double
  let jitterMs: Double
  let decodeMs: Double
  let renderMs: Double
  let bitrateMbps: Double

  init?(_ values: [AnyHashable: Any]?) {
    guard let values,
          let uuid = values["hostUUID"] as? String,
          let fps = values["fps"] as? Double else { return nil }
    hostUUID = uuid
    hostName = values["hostName"] as? String ?? "Host"
    hostAddress = values["hostAddress"] as? String ?? ""
    self.fps = fps
    networkLoss = values["networkLoss"] as? Double ?? 0
    jitterMs = values["jitterMs"] as? Double ?? 0
    decodeMs = values["decodeMs"] as? Double ?? 0
    renderMs = values["renderMs"] as? Double ?? 0
    bitrateMbps = values["bitrateMbps"] as? Double ?? 0
  }
}

private enum HostStatsAddress {
  static func url(_ input: String) -> URL? {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    let value = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
    guard var parts = URLComponents(string: value),
          parts.scheme?.lowercased() == "https",
          let host = parts.host, !host.isEmpty,
          parts.user == nil, parts.password == nil,
          parts.query == nil, parts.fragment == nil else { return nil }
    if parts.port == nil { parts.port = 47990 }
    parts.path = "/api/host/stats"
    return parts.url
  }
}

private final class HostCertificateDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
  let pinnedFingerprint: String?
  private(set) var observedFingerprint: String?

  init(pin: String?) { pinnedFingerprint = pin }

  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
          let trust = challenge.protectionSpace.serverTrust,
          let certificate = SecTrustGetCertificateAtIndex(trust, 0) else {
      completionHandler(.performDefaultHandling, nil)
      return
    }
    if SecTrustEvaluateWithError(trust, nil) {
      completionHandler(.performDefaultHandling, nil)
      return
    }
    let bytes = SecCertificateCopyData(certificate) as Data
    let fingerprint = SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    observedFingerprint = fingerprint
    if pinnedFingerprint == fingerprint {
      completionHandler(.useCredential, URLCredential(trust: trust))
    } else {
      completionHandler(.cancelAuthenticationChallenge, nil)
    }
  }

  func urlSession(_ session: URLSession, task: URLSessionTask,
                  willPerformHTTPRedirection response: HTTPURLResponse,
                  newRequest request: URLRequest,
                  completionHandler: @escaping (URLRequest?) -> Void) {
    // Do not forward the bearer token to any redirect destination.
    completionHandler(nil)
  }
}

@MainActor private final class HostStatsModel: ObservableObject {
  @Published var sample: HostSample?
  @Published var history: [HostSample] = []
  @Published var status = "Enter your VibePollo Web UI address and a read-only API token."
  @Published var untrustedFingerprint: String?
  @Published var updatedAt: Date?
  private var fetching = false
  var visible = false
  private var addressForFingerprint: String?

  private func pinKey(for url: URL) -> String {
    "VibePollo.Certificate.\(url.host ?? "").\(url.port ?? 47990)"
  }

  func reset() {
    sample = nil
    history = []
    untrustedFingerprint = nil
    addressForFingerprint = nil
    updatedAt = nil
    status = "Connect to fetch live host stats."
  }

  func trustCertificate(for address: String) {
    guard let url = HostStatsAddress.url(address),
          addressForFingerprint == url.absoluteString,
          let fingerprint = untrustedFingerprint else { return }
    UserDefaults.standard.set(fingerprint, forKey: pinKey(for: url))
    untrustedFingerprint = nil
    refresh(address: address)
  }

  func refresh(address: String) {
    guard !fetching else { return }
    guard let url = HostStatsAddress.url(address) else {
      status = "Enter a valid HTTPS host address."
      return
    }
    guard let token = HostStatsKeychain.read(for: url.host ?? "") else {
      status = "Save a read-only API token to connect."
      return
    }
    fetching = true
    let pin = UserDefaults.standard.string(forKey: pinKey(for: url))
    let certificateDelegate = HostCertificateDelegate(pin: pin)
    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = 6
    let session = URLSession(configuration: configuration, delegate: certificateDelegate, delegateQueue: nil)
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    Task {
      defer {
        fetching = false
        session.finishTasksAndInvalidate()
      }
      do {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
          status = "No HTTP response from host."
          return
        }
        guard http.statusCode == 200 else {
          status = http.statusCode == 401 || http.statusCode == 403
            ? "Token rejected. Allow GET /api/host/stats in VibePollo."
            : "Host returned HTTP \(http.statusCode)."
          return
        }
        sample = try JSONDecoder().decode(HostSample.self, from: data)
        if let sample {
          history.append(sample)
          if history.count > 150 { history.removeFirst(history.count - 150) }
        }
        status = "Connected"
        untrustedFingerprint = nil
        updatedAt = Date()
      } catch {
        if let fingerprint = certificateDelegate.observedFingerprint,
           fingerprint != pin {
          untrustedFingerprint = fingerprint
          addressForFingerprint = url.absoluteString
          status = "Host certificate needs your approval."
        } else {
          status = "Unable to read host stats: \(error.localizedDescription)"
        }
      }
    }
  }
}

private struct HostStatsView: View {
  @AppStorage("VibePollo.StatsAddress") private var address = ""
  @State private var newToken = ""
  @StateObject private var model = HostStatsModel()
  @State private var stream: StreamSample?
  @State private var fpsHistory: [Double] = []
  @State private var lossHistory: [Double] = []
  private let clock = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
  private let accent = Color(nsColor: CrimsonAppearance.accent)

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 17) {
        HStack {
          Label("HOST PERFORMANCE", systemImage: "waveform.path.ecg")
            .font(.headline)
            .foregroundColor(accent)
          Spacer()
          Text(model.updatedAt.map { "Updated \($0.formatted(date: .omitted, time: .standard))" } ?? "Waiting for host")
            .font(.caption).foregroundColor(.secondary)
        }

        HStack {
          TextField("Host IP or HTTPS address", text: $address)
            .textFieldStyle(.roundedBorder)
            .onChange(of: address) { _ in model.reset() }
          Button("Connect") { model.refresh(address: address) }
        }
        HStack {
          SecureField("Read-only VibePollo API token", text: $newToken)
            .textFieldStyle(.roundedBorder)
          Button("Save Token") {
            if let host = HostStatsAddress.url(address)?.host,
               HostStatsKeychain.save(newToken, for: host) {
              newToken = ""
              model.refresh(address: address)
            } else {
              model.status = "Could not save token to macOS Keychain."
            }
          }
          .disabled(newToken.isEmpty || HostStatsAddress.url(address) == nil)
        }

        Text(model.status).font(.caption).foregroundColor(.secondary)
        if let fingerprint = model.untrustedFingerprint {
          VStack(alignment: .leading, spacing: 8) {
            Text("The host uses a certificate macOS does not trust. Verify this SHA-256 fingerprint on your VibePollo host before trusting it:")
              .font(.caption)
            Text(fingerprint).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
            Button("Trust This Host Certificate") { model.trustCertificate(for: address) }
          }
          .padding(12)
          .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: CrimsonAppearance.surface)))
        }

        if let sample = model.sample {
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metric("CPU", value: percent(sample.cpu_percent), detail: degrees(sample.cpu_temp_c), fraction: sample.cpu_percent)
            metric("GPU", value: percent(sample.gpu_percent), detail: degrees(sample.gpu_temp_c), fraction: sample.gpu_percent)
            metric("RAM", value: percent(ratio(sample.ram_used_bytes, sample.ram_total_bytes)),
                   detail: bytes(sample.ram_used_bytes) + " / " + bytes(sample.ram_total_bytes),
                   fraction: ratio(sample.ram_used_bytes, sample.ram_total_bytes))
            metric("VRAM", value: percent(ratio(sample.vram_used_bytes, sample.vram_total_bytes)),
                   detail: bytes(sample.vram_used_bytes) + " / " + bytes(sample.vram_total_bytes),
                   fraction: ratio(sample.vram_used_bytes, sample.vram_total_bytes))
            metric("GPU ENCODER", value: percent(sample.gpu_encoder_percent), detail: "Host encoder", fraction: sample.gpu_encoder_percent)
            metric("NETWORK", value: "↓ " + rate(sample.net_rx_bps),
                   detail: "↑ " + rate(sample.net_tx_bps), fraction: nil)
          }
          Text("HOST HISTORY · LAST 5 MINUTES")
            .font(.caption.weight(.bold)).tracking(1.2).foregroundColor(accent)
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            historyGraph("CPU", values: model.history.map { $0.cpu_percent ?? -1 }, maximum: 100)
            historyGraph("GPU", values: model.history.map { $0.gpu_percent ?? -1 }, maximum: 100)
            historyGraph("RAM", values: model.history.map { ratio($0.ram_used_bytes, $0.ram_total_bytes) ?? -1 }, maximum: 100)
            historyGraph("VRAM", values: model.history.map { ratio($0.vram_used_bytes, $0.vram_total_bytes) ?? -1 }, maximum: 100)
          }
        }
        if let stream, isSameHost(stream) {
          Text("STREAM HEALTH · \(stream.hostName.uppercased())")
            .font(.caption.weight(.bold)).tracking(1.2).foregroundColor(accent)
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metric("RENDERED FPS", value: String(format: "%.0f", stream.fps),
                   detail: String(format: "%.1f Mbps video", stream.bitrateMbps), fraction: nil)
            metric("NETWORK LOSS", value: String(format: "%.1f%%", stream.networkLoss),
                   detail: String(format: "Jitter %.1f ms", stream.jitterMs), fraction: stream.networkLoss)
            metric("DECODE", value: String(format: "%.1f ms", stream.decodeMs), detail: "Client video decode", fraction: nil)
            metric("RENDER", value: String(format: "%.1f ms", stream.renderMs), detail: "Client presentation", fraction: nil)
          }
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            historyGraph("FPS · 5 MIN", values: fpsHistory, maximum: max(60, (fpsHistory.max() ?? 60) * 1.1))
            historyGraph("LOSS · 5 MIN", values: lossHistory, maximum: max(5, (lossHistory.max() ?? 0) * 1.1))
          }
        }
        Text("Create a VibePollo token scoped only to GET /api/host/stats. The host's Web UI must be reachable from this Mac.")
          .font(.caption).foregroundColor(.secondary)
      }
      .padding(20)
    }
    .onReceive(clock) { _ in if model.visible { model.refresh(address: address) } }
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("MoonlightStreamStatsSample"))) { note in
      guard let next = StreamSample(note.userInfo) else { return }
      if stream?.hostUUID != next.hostUUID {
        fpsHistory = []
        lossHistory = []
      }
      stream = next
      fpsHistory.append(next.fps)
      lossHistory.append(next.networkLoss)
      if fpsHistory.count > 150 { fpsHistory.removeFirst(fpsHistory.count - 150) }
      if lossHistory.count > 150 { lossHistory.removeFirst(lossHistory.count - 150) }
    }
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("MoonlightStreamStatsEnded"))) { note in
      if stream?.hostUUID == note.object as? String { stream = nil; fpsHistory = []; lossHistory = [] }
    }
    .onAppear { model.visible = true; model.refresh(address: address) }
    .onDisappear { model.visible = false }
  }

  private func isSameHost(_ stream: StreamSample) -> Bool {
    guard let configured = HostStatsAddress.url(address)?.host else { return true }
    return HostStatsAddress.url(stream.hostAddress)?.host?.caseInsensitiveCompare(configured) == .orderedSame
  }

  private func historyGraph(_ title: String, values: [Double], maximum: Double) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(title).font(.caption.weight(.semibold)).foregroundColor(accent)
        Spacer()
        Text("5 min").font(.caption2).foregroundColor(.secondary)
      }
      HistoryLine(values: values, maximum: maximum)
        .frame(height: 70)
    }
    .padding(12)
    .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: CrimsonAppearance.surface)))
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(nsColor: CrimsonAppearance.border)))
  }

  private func metric(_ title: String, value: String, detail: String, fraction: Double?) -> some View {
    VStack(alignment: .leading, spacing: 9) {
      Text(title).font(.caption.weight(.bold)).tracking(1.3).foregroundColor(accent)
      Text(value).font(.system(size: 26, weight: .semibold, design: .rounded))
      Text(detail).font(.caption).foregroundColor(.secondary)
      if let fraction, fraction >= 0 {
        ProgressView(value: min(100, fraction), total: 100).tint(accent)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
    .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: CrimsonAppearance.surface)))
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(nsColor: CrimsonAppearance.border)))
  }

  private func percent(_ value: Double?) -> String {
    guard let value, value >= 0, value.isFinite else { return "N/A" }
    return String(format: "%.0f%%", value)
  }
  private func degrees(_ value: Double?) -> String {
    guard let value, value >= 0, value.isFinite else { return "Temperature unavailable" }
    return String(format: "%.0f °C", value)
  }
  private func ratio(_ used: Double?, _ total: Double?) -> Double? {
    guard let used, let total, total > 0, used >= 0 else { return nil }
    return used * 100 / total
  }
  private func bytes(_ value: Double?) -> String {
    guard let value, value >= 0 else { return "N/A" }
    return ByteCountFormatter.string(fromByteCount: Int64(value), countStyle: .binary)
  }
  private func rate(_ value: Double?) -> String {
    guard let value, value >= 0 else { return "N/A" }
    return ByteCountFormatter.string(fromByteCount: Int64(value), countStyle: .decimal) + "/s"
  }
}

private struct HistoryLine: View {
  let values: [Double]
  let maximum: Double

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Path { path in
          for fraction in [0.25, 0.5, 0.75] {
            let y = geometry.size.height * fraction
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
          }
        }
        .stroke(Color(nsColor: CrimsonAppearance.border).opacity(0.6), lineWidth: 0.5)

        Path { path in
          var started = false
          // Fixed 150-point time axis; newly connected hosts fill from the right.
          for (index, value) in values.suffix(150).enumerated() {
            if value < 0 || !value.isFinite { started = false; continue }
            let x = geometry.size.width * CGFloat(150 - min(values.count, 150) + index) / 149
            let y = geometry.size.height * (1 - CGFloat(min(max(value, 0), maximum) / max(maximum, 1)))
            let point = CGPoint(x: x, y: y)
            if started { path.addLine(to: point) } else { path.move(to: point); started = true }
          }
        }
        .stroke(Color(nsColor: CrimsonAppearance.accent), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
      }
    }
  }
}
