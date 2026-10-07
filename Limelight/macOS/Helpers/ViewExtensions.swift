//
//  ViewExtensions.swift
//  Moonlight for macOS
//
//  Created by Michael Kenny on 17/1/2024.
//  Copyright © 2024 Moonlight Game Streaming Project. All rights reserved.
//

import AppKit
import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func availableMonospacedDigit() -> some View {
        if #available(macOS 12.0, *) {
            self.monospacedDigit()
        }
    }
    
    @ViewBuilder func adaptiveForegroundColor(_ color: Color) -> some View {
        if #available(macOS 12.0, *) {
            self.foregroundStyle(color)
        } else {
            self.foregroundColor(color)
        }
    }
}


// Navigation and floating controls only. Content remains on native opaque surfaces.
private struct MoonlightNavigationGlass: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    let radius: CGFloat

    @ViewBuilder func body(content: Content) -> some View {
        if reduceTransparency || contrast == .increased {
            content.background(Color(nsColor: .windowBackgroundColor),
                               in: RoundedRectangle(cornerRadius: radius))
        } else if #available(macOS 26.0, *) {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: radius))
        } else {
            content.background(.regularMaterial, in: RoundedRectangle(cornerRadius: radius))
        }
    }
}

extension View {
    func moonlightNavigationGlass(cornerRadius: CGFloat = 16) -> some View {
        modifier(MoonlightNavigationGlass(radius: cornerRadius))
    }
}

// A background-only AppKit bridge. Callers retain their existing controls,
// responder chain, sizing and callbacks; this never owns a streaming surface.
@objc(MLNavigationMaterial) final class MLNavigationMaterial: NSObject {
    @objc(makeViewWithFrame:cornerRadius:)
    static func makeView(frame: NSRect, cornerRadius: CGFloat) -> NSView {
        MoonlightMaterialBackground(frame: frame, radius: cornerRadius)
    }
}

private final class MoonlightMaterialBackground: NSView {
    private let radius: CGFloat
    private var displayObserver: NSObjectProtocol?

    init(frame: NSRect, radius: CGFloat) {
        self.radius = radius
        super.init(frame: frame)
        refreshMaterial()
        displayObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in self?.refreshMaterial() }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    deinit {
        if let displayObserver { NSWorkspace.shared.notificationCenter.removeObserver(displayObserver) }
    }

    // The background is decorative: pointer events belong to the existing controls.
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        refreshMaterial()
    }

    private func refreshMaterial() {
        subviews.forEach { $0.removeFromSuperview() }
        wantsLayer = true
        layer?.backgroundColor = nil
        let workspace = NSWorkspace.shared
        if workspace.accessibilityDisplayShouldReduceTransparency || workspace.accessibilityDisplayShouldIncreaseContrast {
            effectiveAppearance.performAsCurrentDrawingAppearance {
                layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
                layer?.borderColor = NSColor.separatorColor.cgColor
            }
            layer?.borderWidth = 1
            layer?.cornerRadius = radius
        } else {
            layer?.borderWidth = 0
            let material: NSView
            if #available(macOS 26.0, *) {
                let glass = NSGlassEffectView(frame: bounds)
                glass.cornerRadius = radius
                glass.contentView = NSView(frame: bounds)
                material = glass
            } else {
                let visual = NSVisualEffectView(frame: bounds)
                visual.material = .popover
                visual.blendingMode = .withinWindow
                visual.state = .followsWindowActiveState
                visual.wantsLayer = true
                visual.layer?.cornerRadius = radius
                visual.layer?.masksToBounds = true
                material = visual
            }
            material.autoresizingMask = [.width, .height]
            addSubview(material)
        }
    }
}

@objc(MLCollectionEmptyState) final class MLCollectionEmptyState: NSObject {
    @objc(updateInView:empty:title:detail:symbol:)
    static func update(in view: NSView, empty: Bool, title: String, detail: String, symbol: String) {
        let identifier = NSUserInterfaceItemIdentifier("MoonlightCollectionEmptyState")
        let previous = view.subviews.first { $0.identifier == identifier }
        if !empty {
            previous?.removeFromSuperview()
            return
        }
        let label: NSTextField
        if let previous = previous as? NSTextField {
            label = previous
        } else {
            label = NSTextField(wrappingLabelWithString: "")
            label.identifier = identifier
            label.alignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
                label.widthAnchor.constraint(lessThanOrEqualToConstant: 360)
            ])
        }
        let text = NSMutableAttributedString(string: title + "\n\n", attributes: [
            .font: NSFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: NSColor.labelColor
        ])
        text.append(NSAttributedString(string: detail, attributes: [
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .foregroundColor: NSColor.secondaryLabelColor
        ]))
        let centered = NSMutableAttributedString(string: "")
        if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) {
            image.size = NSSize(width: 32, height: 32)
            let attachment = NSTextAttachment()
            attachment.image = image
            centered.append(NSAttributedString(attachment: attachment))
            centered.append(NSAttributedString(string: "\n\n"))
        }
        centered.append(text)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        centered.addAttribute(.paragraphStyle, value: paragraph,
                              range: NSRange(location: 0, length: centered.length))
        label.attributedStringValue = centered
        label.setAccessibilityLabel(title + ". " + detail)
    }
}
