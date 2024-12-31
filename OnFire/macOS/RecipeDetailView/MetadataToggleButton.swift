//
//  MetadataToggleButton.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 29.12.24.
//

import SwiftUI

struct MetadataToggleButton: View {
    @Binding var showMetadata: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                showMetadata.toggle()
            }
        } label: {
            Image(systemName: showMetadata ? "chevron.down" : "chevron.up")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    MetadataToggleButton(showMetadata: .constant(false))
}
