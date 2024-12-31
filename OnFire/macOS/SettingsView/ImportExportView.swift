//
//  ImportExportView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 30.12.24.
//
#if os(macOS)
import SwiftUI
import SwiftData

struct ImportExportView: View {
    @Query private var recipes: [RecipeModel]
    
    @State private var isImporterPresented = false
    
    let fileHandler = FileHandler.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rezepte importieren/exportieren")
                .font(.headline)
            
            Button("Alle Rezepte exportieren") {
                fileHandler.exportAllRecipes(recipes)
            }
            .buttonStyle(.bordered)
            
            // MARK: der SingleImporter funktioniert wieder nicht.!
            Button("Rezepte importieren...") {
                print("Import… SingleFile")
                fileHandler.initiateImport()
            }
            .buttonStyle(.bordered)
            
            
            Button("Verzeichnis öffnen") {
                isImporterPresented = true
            }
            
            Divider()
            
            Text("Einzelne Rezepte")
                .font(.headline)
            
            ScrollView(.vertical) {
                List {
                    ForEach(recipes) { recipe in
                        HStack {
                            Text(recipe.title)
                                .lineLimit(1)
                            Spacer()
                            Button("Exportieren") {
                                fileHandler.prepareExport(recipeModel: recipe)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2))
                )
            }
        }
        .withFileHandling()
    }
}



#Preview {
    ImportExportView()
}

#endif
