//
//  ViewExtensions.swift
//  Moonlight for macOS
//
//  Created by Michael Kenny on 17/1/2024.
//  Copyright © 2024 Moonlight Game Streaming Project. All rights reserved.
//

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
