//
//  IngredientsToggleButton.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 29.12.24.
//

import SwiftUI


struct IngredientsToggleButton: View {
    @Binding var showIngredients: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                showIngredients.toggle()
            }
        } label: {
            Image(systemName: showIngredients ? "chevron.down" : "chevron.up")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}
