//
//  AboutView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 28.12.24.
//
#if os(macOS)
import SwiftUI

struct AboutView: View {
    // App Information
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App Name"
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    
    var body: some View {
        VStack(spacing: 20) {
            // App Icon
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 128, height: 128)
            
            // App Name und Version
            VStack(spacing: 8) {
                Text(appName)
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Version \(version) (\(build))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Copyright und Credits
            VStack(spacing: 16) {
                Text("© \(String(format: "%d", Calendar.current.component(.year, from: Date()))) knibbelknabbel")
                    .font(.footnote)
                
                Text(String(format: "%d", Calendar.current.component(.year, from: Date())))
                
                Text("Entwickelt mit ♥️ in Deutschland")
                    .font(.footnote)
            }
            
            Spacer()
            
            // Buttons für weitere Aktionen
            HStack(spacing: 12) {
                Button("Website besuchen") {
                    if let url = URL(string: "https://www.knibbelkabbel.de") {
                        NSWorkspace.shared.open(url)
                    }
                }
                
                Button("Support kontaktieren") {
                    if let url = URL(string: "mailto:support@your-domain.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        .padding(40)
        .frame(width: 400, height: 500)
        .background(Color("IconBackground"))
    }
}


#Preview {
    AboutView()
}
#endif
