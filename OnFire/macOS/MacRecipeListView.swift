//
//  MacRecipeListView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 22.12.24.
//
import SwiftUI
import SwiftData
import CookInSwift

struct MacRecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [RecipeModel]
    
    @Binding var selection: RecipeModel? // Für macOS Sidebar-Selection

    // Popup für Kategorie bearbeiten
    @State private var showingCategoryEditor = false
    @State private var selectedRecipeForCategory: RecipeModel?
    @State private var editingCategory = ""
    
    
    
    var body: some View {
        
        List(selection: $selection) {
            ForEach(Dictionary(grouping: recipes, by: { $0.category })
                .sorted(by: { $0.key < $1.key }), id: \.key) { category, recipesInCategory in
                    Section(header: Text(category)) {
                        ForEach(recipesInCategory) { recipe in
                            NavigationLink(value: recipe) {
                                VStack(alignment: .leading) {
                                    Text(recipe.title)
                                        .font(.headline)
                                    Text(recipe.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                //                            }
                                .contextMenu {
                                    Button("Kategorie bearbeiten") {
                                        selectedRecipeForCategory = recipe
                                        editingCategory = recipe.category
                                        showingCategoryEditor = true
                                    }
                                }
                            }
                            //                        .onDelete { indexSet in
                            //                            deleteRecipes(recipes: recipesInCategory, at: indexSet)
                        }
                    }
                }
        }
        .popover(isPresented: $showingCategoryEditor) {
            VStack {
                TextField("Kategorie", text: $editingCategory)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                HStack {
                    Button("Abbrechen") {
                        showingCategoryEditor = false
                    }
                    Button("Speichern") {
                        if let recipe = selectedRecipeForCategory {
                            recipe.category = editingCategory
                        }
                        showingCategoryEditor = false
                    }
                }
                .padding()
            }
            .frame(width: 300)
            .padding()
        }
//        List(selection: $selection) {
//            ForEach(categorizedRecipes) { section in
//                Section(header: Text(section.name)) {
//                    ForEach(section.recipes) { recipe in
//                        NavigationLink(value: recipe) {
//                            VStack(alignment: .leading) {
//                                Text(recipe.title)
//                                    .font(.headline)
//                                Text(recipe.timestamp, style: .date)
//                                    .font(.caption)
//                                    .foregroundStyle(.secondary)
//                            }
//                        }
//                    }
//                    .onDelete { indexSet in
//                        deleteRecipes(from: section, at: indexSet)
//                    }
//                }
//            }
//        }
//
//
    }
//
    private func deleteRecipes(from section: CategorySection, at offsets: IndexSet) {
            for index in offsets {
                let recipe = section.recipes[index]
                modelContext.delete(recipe)
            }
        }
    
//    private func deleteRecipes(offsets: IndexSet) {
//        for index in offsets {
//            modelContext.delete(recipes[index])
//        }
//    }
}
#Preview {
    MacRecipeListView(selection: .constant(nil))
}
