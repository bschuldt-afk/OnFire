//
//  HomeView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 19.12.24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Tab {
                RecipeListView()
            } label: {
                Text("Recipes")
            }
            
            Tab {
                ConfigView()
            } label: {
                Text("Config")
            }
        }
    }
}

#Preview {
    HomeView()
}
