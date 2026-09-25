import AppKit
import SwiftUI

/// Shared palette for the optional application-wide appearance.
@objc final class CrimsonAppearance: NSObject {
  @objc static var isEnabled: Bool { UserDefaults.standard.integer(forKey: "theme") == 3 }
  @objc static var accent: NSColor { NSColor(calibratedRed: 0.78, green: 0.09, blue: 0.18, alpha: 1) }
  @objc static var surface: NSColor { NSColor(calibratedRed: 0.065, green: 0.04, blue: 0.055, alpha: 1) }
  @objc static var border: NSColor { NSColor(calibratedRed: 0.30, green: 0.09, blue: 0.14, alpha: 1) }
  @objc static var controlSurface: NSColor { isEnabled ? surface : .controlBackgroundColor }
}

struct AppAppearance: ViewModifier {
  @AppStorage("theme") private var theme = 0

  func body(content: Content) -> some View {
    content
      .tint(theme == 3 ? Color(nsColor: CrimsonAppearance.accent) : .accentColor)
      .preferredColorScheme(theme == 3 ? .dark : nil)
      .background {
        if theme == 3 { Color(nsColor: CrimsonAppearance.surface) }
      }
  }
}
