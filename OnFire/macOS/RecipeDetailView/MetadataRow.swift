//
//  MetadataRow.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 29.12.24.
//

import SwiftUI


struct MetadataRow: View {
    let key: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(key)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    MetadataRow(key: "Title", value: "Cooklang")
}
