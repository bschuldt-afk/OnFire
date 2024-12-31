//
//  IngredientRow.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 29.12.24.
//

import SwiftUI

struct IngredientRow: View {
    let name: String
    let amount: String
    let isEven: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .fontWeight(.medium)
            Spacer()
            Text(amount)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isEven ? Color.secondary.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

#Preview {
    IngredientRow(name: "Flour", amount: "100g", isEven: true)
}
