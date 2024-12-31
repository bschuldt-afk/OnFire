//
//  MacAddRecipeView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 22.12.24.
//

import SwiftUI

struct MacAddRecipeView: View {
    // Umgebungsvariablen für die Datenverwaltung
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // State-Variablen für die Eingabefelder
    @State private var title: String = ""
    @State private var content: String = ""
    
    @State private var showPopover = false
    @State private var showingRecipeFields = false
    
    // Beispielrezept als Vorlage
    private let templateRecipe = """
    >> servings: 4
    >> time: 30 minutes
    >> source: Your Kitchen
    
    [instructions]
    1. Add your cooking steps here
    2. Use @ingredient{amount%unit} for ingredients
    3. Use #tool for cookware
    4. Use ~timer{time%unit} for timing
    """
    
    var body: some View {
        #if os(macOS)
        HSplitView {
            HStack {
                VStack {
                    TextField("Titel eingeben", text: $title)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Cooklang Formatierung:")
                                .font(.subheadline)
                            Text("• @zutat{menge%einheit} für Zutaten").font(.caption)
                                .frame(height: 20)
                            Text("• #werkzeug für Kochutensilien").font(.caption)
                            Text("• ~timer{zeit%einheit} für Zeitangaben").font(.caption)
                        }
                        Spacer()
                        Button {
                            showPopover.toggle()
                        } label: {
                            Image(systemName: "text.page.fill")
                        }
                    }
                    .padding(10)
                    .background(Color("CookLangFormatierungBkgColor"))
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    
                    HStack {
                        Label {
                            Text("Rezept:")
                        } icon: {
                            Image(systemName: "pencil.circle")
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 300)
                        .font(.system(.body, design: .monospaced))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary, lineWidth: 1).opacity(0.2)
                        }
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Abbrechen") {
                            dismiss()
                        }
                        Spacer()
                        Button {
                            showingRecipeFields.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("Rezept-Hilfe")
                            }
                        }
                        Button("Vorlage einfügen") {
                            // Fügt die Vorlage nur ein, wenn der Content leer ist
                            if content.isEmpty {
                                content = templateRecipe
                            }
                        }
                        
                        Button("Speichern") {
                            saveRecipe()
                        }
                    }
                    .padding()
                }
                
                
                if showingRecipeFields {
                    MacRecipeFieldListView()
                        .frame(maxWidth: 300)
                }
            }
        }
        #endif
    }
    
    // Funktion zum Speichern des Rezepts
    private func saveRecipe() {
        let recipe = RecipeModel(title: title, content: content)
        modelContext.insert(recipe)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern des Rezepts: \(error)")
            // Hier könnte man einen Alert anzeigen
        }
    }
}

#Preview {
    MacAddRecipeView()
}
