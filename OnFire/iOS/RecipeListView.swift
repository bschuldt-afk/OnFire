//
//  RecipeListView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 17.12.24.
//

import SwiftUI
import SwiftData
import CookInSwift

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var recipes: [RecipeModel]
    
    @State private var showingAddRecipe = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    #if os(iOS)
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(recipe.title)
                                .font(.headline)
                            Text(recipe.timestamp, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
#endif
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("Rezepte")
            .toolbar {
                Button("Neues Rezept") {
                    showingAddRecipe = true
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
    }
}



#Preview {
    RecipeListView()
}
