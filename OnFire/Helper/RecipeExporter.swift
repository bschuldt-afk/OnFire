//
//  RecipeExporter.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 19.12.24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// UTType-Definition als globale Konstante
private let cookFileType = UTType(exportedAs: "com.knibbelknabbel.cook", conformingTo: .text)


@MainActor
class RecipeExportManager: ObservableObject {
    // Referenz auf die globale cookType
//    static var cookType: UTType { self.cookType }
    static var cookType: UTType { cookFileType }
    
    @Published var isExporting = false
    @Published var currentRecipe: RecipeModel?
    
    var exportDocument: CookDocument? {
        guard let recipe = currentRecipe else { return nil }
        return CookDocument(content: recipe.content)
    }
    
    var exportFilename: String {
        guard let recipe = currentRecipe else { return "recipe.cook" }
        return recipe.title.appending(".cook")
    }
    
    func exportRecipe(_ recipe: RecipeModel) {
        currentRecipe = recipe
        isExporting = true
    }
}

struct RecipeExportViewModifier: ViewModifier {
    @ObservedObject var exportManager: RecipeExportManager
    
    func body(content: Content) -> some View {
        content.fileExporter(
            isPresented: $exportManager.isExporting,
            document: exportManager.exportDocument,
            contentType: cookFileType, // Direkter Zugriff auf die globale Konstante
            defaultFilename: exportManager.exportFilename
        ) { result in
            switch result {
            case .success(let url):
                print("Erfolgreich exportiert: \(url)")
            case .failure(let error):
                print("Fehler beim Export: \(error)")
            }
        }
    }
}

extension View {
    func recipeExporter(using manager: RecipeExportManager) -> some View {
        modifier(RecipeExportViewModifier(exportManager: manager))
    }
}

class CookDocument: FileDocument {
    // Direkter Zugriff auf die globale cookType Konstante
//    static var readableContentTypes: [UTType] { [cookType] }
    static var readableContentTypes: [UTType] { [cookFileType] }
    
    let content: String
    
    init(content: String) {
        self.content = content
    }
    
    required init(configuration: ReadConfiguration) throws {
        content = ""
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}
