//
//  MacCategoryListView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 23.12.24.
//

import SwiftUI
import SwiftData
import CookInSwift

struct MacCategoryListView: View {
    @AppStorage("isDarkMode") var isDarkMode = false
    
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [RecipeModel]
    
    private var categorizedRecipes: [CategorySection] {
        let grouped = Dictionary(grouping: recipes) { recipe in
            recipe.category
        }
        
        return grouped.map { category, recipes in
            CategorySection(name: category, recipes: recipes)
        }.sorted { $0.name < $1.name }
    }
    
    @State var serachText: String = ""
    var body: some View {
        
        
        VStack {
            Text("Kategorie")
            
            ForEach(categorizedRecipes) { category in
                Button {
                    print("Category: \(category.name)")
                } label: {
                    Text(category.name)
                }
                .buttonStyle(.plain)
                .padding()
            }
            
            Spacer()
            
            Image(isDarkMode ? "OnFire_Dunkel_1024x1024" : "OnFire_Hell_1024x1024")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom)
            
        }
        .frame(width: 220)
        .background(Color("IconBackground"))
    }
    
}

#Preview {
    MacCategoryListView()
}
