//
//  MacHomeView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 22.12.24.
//
#if os(macOS)
import SwiftUI

struct MacHomeView: View {
    
    @State private var selection: RecipeModel? // Für macOS Sidebar-Selection
    @State private var showInfoView: Bool = false
    
    var body: some View {
//        Group {
        NavigationSplitView {
            
            VSplitView {
                MacCategoryListView()
                
                SettingsLink {
                    Text("Settings")
                    
                }
                .frame(height: 50)
                .keyboardShortcut("s", modifiers: .command)
                
            }
            .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            
        } content: {
            MacRecipeFilteredListView(selection: $selection)
//                MacRecipeListView(selection: $selection)
                .toolbar {
                    ToolbarItem(id: "addRecipe") {
                        NavigationLink {
                            MacAddRecipeView()
                        } label: {
                            Label("Neues Rezept", systemImage: "plus")
                                .labelStyle(.iconOnly)
                        }
                        .keyboardShortcut("n", modifiers: .command)
                    }
                }
            } detail: {
                if let selection {
                    MacRecipeDetailView(recipeModel: selection)
                } else {
                    
                    ContentUnavailableView("Kein Rezept", systemImage: "cooktop")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            
        }
//    }
}

#Preview {
    MacHomeView()
}

#endif
