//
//  MaccRecipeFieldListView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 22.12.24.
//

import SwiftUI

struct MacRecipeFieldListView: View {
    
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = RecipeFieldsViewModel()
    
    var body: some View {
        
        List(viewModel.fields) { field in
            VStack(alignment: .leading, spacing: 8) {
                // Befehl
                Text(field.command)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                // Erklärung
                Text(field.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Beispiel
                HStack {
                    Text("Beispiel:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(field.example)
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 4)
        }
        .onAppear {
            viewModel.loadFields()
        }
    }
}



#Preview {
    MacRecipeFieldListView()
}
