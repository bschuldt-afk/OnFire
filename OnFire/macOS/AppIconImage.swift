//
//  AppIconImage.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 28.12.24.
//
#if os(macOS)
import SwiftUI

struct AppIconImage: View {
    var body: some View {
        Group {
            if let nsImage = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .frame(width: 128, height: 128)
                    .cornerRadius(16)
            } else {
                // Ein moderner Fallback mit SF Symbols
                Image(systemName: "app.fill")
                    .resizable()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .frame(width: 128, height: 128)
            }
        }
    }
}

#Preview {
    AppIconImage()
}
#endif
