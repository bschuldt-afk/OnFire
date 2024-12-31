//
//  MacInfoView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 23.12.24.
//
#if os(macOS)
import SwiftUI
import SwiftData
import UniformTypeIdentifiers // Benötigt für die Dateitypendefinition


struct MacInfoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [RecipeModel]
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    // State für den FileExporter
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportData: ExportData? = nil
    
    // Definiere einen eigenen UTType für .cook Dateien
    static let cookType = UTType(exportedAs: "com.knibbelknabbel.cook", conformingTo: .text)
    
    var body: some View {
        List {
            Section {
                Toggle("Dark Mode", isOn: $isDarkMode)
                    .toggleStyle(.switch)
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
            Spacer()
        }
        .padding(.horizontal)
        .frame(width: 220)
        .preferredColorScheme(isDarkMode ? .dark : .light)
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

#Preview {
    MacInfoView()
}
#endif
