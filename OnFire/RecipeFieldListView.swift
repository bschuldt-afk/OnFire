import SwiftUI

// Datenmodell für ein Rezeptfeld
struct RecipeField: Codable, Identifiable {
    let id = UUID()
    let command: String
    let description: String
    let example: String
    
    enum CodingKeys: String, CodingKey {
        case command, description, example
    }
}

// Wrapper für die JSON-Struktur
struct RecipeSchema: Codable {
    let recipeFields: [RecipeField]
}

// ViewModel
class RecipeFieldsViewModel: ObservableObject {
    @Published var fields: [RecipeField] = []
    
    func loadFields() {
        guard let url = Bundle.main.url(forResource: "simplified-recipe-schema", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Fehler beim Laden der JSON-Datei")
            return
        }
        
        do {
            let schema = try JSONDecoder().decode(RecipeSchema.self, from: data)
            fields = schema.recipeFields
        } catch {
            print("Decodierung fehlgeschlagen: \(error)")
        }
    }
}


// ALTERNATIVE
struct RecipeFieldListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = RecipeFieldsViewModel()
    
    var body: some View {
        
        ZStack {
            Button("OK") {
                dismiss()
            }
            .bold()
            .tint(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.blue)

        
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
        Button("OK") {
            dismiss()
        }
        .onAppear {
            viewModel.loadFields()
        }
    }
}

// Optional: Eine alternative Darstellung mit DisclosureGroup
struct RecipeFieldExpandableListView: View {
    @StateObject private var viewModel = RecipeFieldsViewModel()
    
    var body: some View {
        List(viewModel.fields) { field in
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 8) {
                    // Erklärung
                    Text("Erklärung:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(field.description)
                        .padding(.leading)
                    
                    // Beispiel
                    Text("Beispiel:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(field.example)
                        .padding(.leading)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            } label: {
                Text(field.command)
                    .font(.headline)
            }
        }
        .onAppear {
            viewModel.loadFields()
        }
    }
}

#Preview {
    
                RecipeFieldListView()

            
}

// Hauptansicht
struct RecipeFieldsTableView: View {
    @StateObject private var viewModel = RecipeFieldsViewModel()
    
    var body: some View {
        ScrollView {
            Text("Oben")
                .font(.title)
            
            ForEach(viewModel.fields, id: \.id) { field in
             
                Text("\(field.example)")
            }
        }
        
        
        
        
//        Table(viewModel.fields) {
//            TableColumn("Befehl", value: \.command)
//                .width(min: 100, ideal: 150)
//            
//            TableColumn("Erklärung") { field in
//                Text(field.description)
//                    .lineLimit(2)
//            }
//            .width(min: 200, ideal: 300)
//            
//            TableColumn("Beispiel") { field in
//                Text(field.example)
//                    .lineLimit(1)
//            }
//            .width(min: 150, ideal: 200)
//        }
//        .onAppear {
//            viewModel.loadFields()
//        }
    }
}

// Vorschau
//struct RecipeFieldsTableView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeFieldsTableView()
//    }
//}
