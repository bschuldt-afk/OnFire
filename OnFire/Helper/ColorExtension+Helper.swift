//
//  ColorExtension+Helper.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 25.12.24.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif


extension Color {
    // Konvertiert Color zu RGB-Werten
    #if os(macOS)
    var rgbComponents: (red: Double, green: Double, blue: Double) {
        let nsColor = NSColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Konvertiere zu RGB-Farbraum falls nötig
        guard let colorInRGB = nsColor.usingColorSpace(.sRGB) else {
            return (0, 0, 0) // Fallback falls Konvertierung fehlschlägt
        }
        
        colorInRGB.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue)
    }
    #else
    var rgbComponents: (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue)
    }
#endif
}

extension Color {
    func darker(by percentage: Double, colorScheme: ColorScheme) -> Color {
        // Hier können wir unterschiedliche Logik für Dark/Light implementieren
        switch colorScheme {
        case .dark:
            return self.opacity(1 - (percentage * 0.7))  // Weniger dunkel im Dark Mode
        case .light:
            return self.opacity(1 - percentage)
        @unknown default:
            return self.opacity(1 - percentage)
        }
    }
}
