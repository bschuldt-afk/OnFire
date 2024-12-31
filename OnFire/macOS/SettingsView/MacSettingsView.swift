//
//  MacSettingsView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 26.12.24.
//

#if os(macOS)
import SwiftData
import SwiftUI
import Observation
import AppKit

import UniformTypeIdentifiers // Benötigt für die Dateitypendefinition

@Observable
class SettingsViewModel {
    
    
    // Statt direktem @AppStorage verwenden wir eine computed property
    var isDarkMode: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isDarkMode")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDarkMode")
            updateAppearance(for: newValue)
        }
    }
    
    // Gleiche Struktur für andere persistente Einstellungen
    var notificationsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "notifications")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notifications")
        }
    }
    
    private func updateAppearance(for isDark: Bool) {
        let appearance = isDark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
        NSApp.appearance = appearance
        
        // Update alle existierenden Fenster
        for window in NSApp.windows {
            window.appearance = appearance
        }
    }
    
    init() {
        // Prüfe und setze initiale Appearance
        if let currentAppearance = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
            let shouldBeDark = currentAppearance == .darkAqua
            // Nur setzen wenn nötig, um unnötige Updates zu vermeiden
            if shouldBeDark != isDarkMode {
                isDarkMode = shouldBeDark
            }
        }
    }
}

struct MacSettingsView: View {
    @State private var settings = SettingsViewModel()
    @Environment(\.modelContext) private var modelContext
//    @Query private var recipes: [RecipeModel]
    
    // State für den FileExporter
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var isImporterPresented = false
    @State private var exportData: ExportData? = nil
    
    @State private var cookFiles: [String] = []
    @State private var errorMessage: String?
    
//    let fileHandler = FileHandler.shared
    
    // Definiere einen eigenen UTType für .cook Dateien
    static let cookType = UTType(exportedAs: "com.knibbelknabbel.cook", conformingTo: .text)
    
    var body: some View {
 
        TabView {
            // MARK: - Allgemeine Einstellungen
            Form {
                Section("Darstellung") {
                    Toggle("Dark Mode verwenden", isOn: $settings.isDarkMode)
                        .toggleStyle(.switch)
                        .help("Wechselt zwischen hellem und dunklem Erscheinungsbild")
                }

            }
            .formStyle(.grouped)
            .padding()
            .frame(width: 450)
            .tabItem {
                Label("Allgemein", systemImage: "gear")
            }
            
            // MARK: - Import/Export
            Form {
                Section("Datenverwaltung") {
                    
                    ImportExportView()
                    
                }
            }
            .formStyle(.grouped)
            .padding()
            .frame(width: 450)
            .tabItem {
                Label("Import/Export", systemImage: "square.and.arrow.up.on.square")
            }
            // FileExporter wird als Sheet präsentiert
            .fileExporter(
                isPresented: $isExporting,
                document: exportData.map { data in
                    // Verwende die neue CookDocument Klasse
                    CookDocument(content: data.content)
                },
                contentType: Self.cookType,
                defaultFilename: "\(exportData?.filename ?? "recipe").cook"
            ) { result in
                switch result {
                case .success(let url):
                    print("Erfolgreich exportiert: \(url)")
                case .failure(let error):
                    print("Fehler beim Export: \(error)")
                }
            }
            .withFileHandling() 
            // MARK: - Über
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        AppIconImage()
                        
                        Text(Bundle.main.appName)
                            .font(.title)
                        Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        Text("© 2024 Knibbelknabbel")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .formStyle(.grouped)
            .padding()
            .frame(width: 450)
            .tabItem {
                Label("Über", systemImage: "info.circle")
            }
        }
        .frame(height: 450)
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [UTType.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let selectedDir = urls.first {
                    loadCookFiles(from: selectedDir)
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func loadCookFiles(from directoryURL: URL) {
            do {
                // Zugriffsberechtigung für das ausgewählte Verzeichnis anfordern
                guard directoryURL.startAccessingSecurityScopedResource() else {
                    errorMessage = "Keine Berechtigung für das Verzeichnis"
                    return
                }
                defer { directoryURL.stopAccessingSecurityScopedResource() }
                
                let fileManager = FileManager.default
                let files = try fileManager.contentsOfDirectory(
                    at: directoryURL,
                    includingPropertiesForKeys: nil
                )
                
                for fileURL in files.filter({ $0.pathExtension == "cook" }) {
                    do {
                        let content = try String(contentsOf: fileURL, encoding: .utf8)
                        let filename = fileURL.deletingPathExtension().lastPathComponent
                        
                        let newRecipe = RecipeModel(
                            title: filename,
                            content: content
                        )
                        
                        modelContext.insert(newRecipe)
                    } catch {
                        print("Fehler beim Verarbeiten von \(fileURL.lastPathComponent): \(error.localizedDescription)")
                    }
                }
                
                // Speichern aller Änderungen
                try modelContext.save()
                errorMessage = nil
                
                if cookFiles.isEmpty {
                    errorMessage = "Keine .cook Dateien im Verzeichnis gefunden"
                } else {
                    errorMessage = nil
                }
                
            } catch {
                errorMessage = "Fehler beim Einlesen: \(error.localizedDescription)"
            }
        }
}


#Preview {
    MacSettingsView()
}
#endif
