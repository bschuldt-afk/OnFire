//
//  cooklang_claudeApp.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 17.12.24.
//

import SwiftUI
import SwiftData

@main
struct cooklang_claudeApp: App {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App Name"
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: RecipeModel.self, AppearanceSettings.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        
            #if os(macOS)
        WindowGroup {
            MacHomeView()
                .modelContainer(container)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        // Im Menü
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("Über \(Bundle.main.appName)") {
                    showAboutWindow()
                }
            }
        }
        
        Settings {
            MacSettingsView()
                .modelContainer(container)
        }
    
            #else
        WindowGroup {
            HomeView()
                .modelContainer(container)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
            #endif
    }
    
    #if os(macOS)
    private func showAboutWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.contentView = NSHostingView(rootView: AboutView())
        window.makeKeyAndOrderFront(nil)
        
        // Optional: Gib dem Fenster einen eindeutigen Identifier
        window.identifier = NSUserInterfaceItemIdentifier("about-window")
        
        // Optional: Setze einen Titel für das Fenster
        window.title = "Über \(Bundle.main.appName)"
    }
    #endif
}

extension Bundle {
    var appName: String {
        // Versuche zunächst den Anzeigenamen zu bekommen
        if let displayName = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return displayName
        }
        // Falls kein Anzeigename existiert, verwende den Bundle-Namen
        return object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"
    }
}
