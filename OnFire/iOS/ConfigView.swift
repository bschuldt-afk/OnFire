//
//  ConfigView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 19.12.24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers // Benötigt für die Dateitypendefinition
import Observation

@Model
class AppearanceSettings {
    // Using an optional Bool allows us to represent three states:
    // nil = follow system
    // true = always dark
    // false = always light
    var isDarkMode: Bool?
    
    init(isDarkMode: Bool? = nil) {
        self.isDarkMode = isDarkMode
    }
}

// Create an AppearanceManager to handle the logic
@Observable
class AppearanceManager {
    private var settings: AppearanceSettings?
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }
    
    private func loadSettings() {
        // Try to fetch existing settings
        let descriptor = FetchDescriptor<AppearanceSettings>()
        if let existingSettings = try? modelContext.fetch(descriptor).first {
            settings = existingSettings
        } else {
            // Create new settings if none exist
            let newSettings = AppearanceSettings()
            modelContext.insert(newSettings)
            settings = newSettings
            try? modelContext.save()
        }
    }
    
    var colorScheme: ColorScheme? {
        settings?.isDarkMode.map { $0 ? .dark : .light }
    }
    
    func setAppearanceMode(_ mode: AppearanceMode) {
        settings?.isDarkMode = mode == .system ? nil : (mode == .dark)
        try? modelContext.save()
    }
    
    enum AppearanceMode: String, CaseIterable {
        case system = "Follow System"
        case light = "Light Mode"
        case dark = "Dark Mode"
        
        var isDarkMode: Bool? {
            switch self {
            case .system: return nil
            case .light: return false
            case .dark: return true
            }
        }
    }
}



struct ConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [RecipeModel]
    
    @State private var darkMode: Bool = false
    // State für den FileExporter
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportData: ExportData? = nil
    
    // Create an instance of AppearanceManager
    @State private var appearanceManager: AppearanceManager?
    @State private var selectedMode: AppearanceManager.AppearanceMode = .system
    
    // Definiere einen eigenen UTType für .cook Dateien
    static let cookType = UTType(exportedAs: "com.knibbelknabbel.cook", conformingTo: .text)
        
    struct ExportData: Codable {
        let filename: String
        let content: String
    }
    
   
    
    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $selectedMode) {
                    ForEach(AppearanceManager.AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedMode) { _, newValue in
                    appearanceManager?.setAppearanceMode(newValue)
                }
            } header: {
                Text("Appearance")
            }
            
            Section {
                Button {
                    isImporting = true
                } label: {
                    Text("Import")
                }
                
                // Liste aller Rezepte mit Export-Button
                ForEach(recipes) { recipe in
                    HStack {
                        Text(recipe.title)
                        Spacer()
                        Button("Export") {
                            prepareExport(recipe: recipe)
                        }
                    }
                }
            } header: {
                Text("Recipes")
            }
        }
        // FileImporter
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [Self.cookType],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let selectedFile = urls.first else { return }
                importRecipe(from: selectedFile)
                
            case .failure(let error):
                print("Fehler beim Import: \(error)")
            }
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
        .onAppear {
            // Initialize AppearanceManager if not already done
            if appearanceManager == nil {
                appearanceManager = AppearanceManager(modelContext: modelContext)
            }
        }
        .preferredColorScheme(appearanceManager?.colorScheme)
    }
    
    private func prepareExport(recipe: RecipeModel) {
        let safeFilename = recipe.title
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
        
        exportData = ExportData(
            filename: safeFilename, // Ohne Erweiterung
            content: recipe.content
        )
        isExporting = true
    }
    
    // MARK: - Dateiimport
    private func importRecipe(from url: URL) {
            guard url.startAccessingSecurityScopedResource() else {
                print("Zugriff auf Datei nicht möglich")
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let filename = url.deletingPathExtension().lastPathComponent
                
                // Erstelle ein neues RecipeModel
                let newRecipe = RecipeModel(
                    title: filename,
                    content: content
                )
                
                // Speichere in SwiftData
                modelContext.insert(newRecipe)
                try modelContext.save()
                
                print("Rezept erfolgreich importiert")
                
            } catch {
                print("Fehler beim Lesen der Datei: \(error)")
            }
        }
    
}


struct TextFile: FileDocument {
    // Definiere den Cook-Dateityp als den primären Typ
    static var readableContentTypes: [UTType] = [ConfigView.cookType]
    
    var text: String
    var filename: String
    
    init(initialText: String, filename: String) {
        text = initialText
        self.filename = filename
    }
    
    init(configuration: ReadConfiguration) throws {
        text = ""
        filename = "recipe.cook"
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        // Erstelle einen FileWrapper mit explizitem Dateityp
        let wrapper = FileWrapper(regularFileWithContents: data)
        // Setze den Dateinamen ohne zusätzliche Erweiterung
        wrapper.preferredFilename = filename
        return wrapper
    }
}


#Preview {
    ConfigView()
}
