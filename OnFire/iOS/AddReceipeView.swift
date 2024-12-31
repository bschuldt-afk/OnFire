//
//  AddReceipeView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 18.12.24.
//

import SwiftUI
import SwiftData
import CookInSwift

struct AddRecipeView: View {
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
    
    [ingredients]
    @ingredient{amount%unit}
    
    [instructions]
    1. Add your cooking steps here
    2. Use @ingredient{amount%unit} for ingredients
    3. Use #tool for cookware
    4. Use ~timer{time%unit} for timing
    """
    
    var body: some View {
        NavigationStack {
            
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
            .background(Color.secondary)
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
                Spacer()
                
                Button("Vorlage einfügen") {
                    // Fügt die Vorlage nur ein, wenn der Content leer ist
                    if content.isEmpty {
                        content = templateRecipe
                    }
                }
            }
            .padding()
            .navigationTitle("Neues Rezept")
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Speichern") {
                        saveRecipe()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            #else
            .toolbar {
                ToolbarItem(id: "showRecipeFields") {
                    Button {
                        showingRecipeFields = true
                    } label: {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Rezept-Hilfe")
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveRecipe()
                    }
//                    .disabled(editedTitle.isEmpty || editedContent.isEmpty)
                }
            }
            #endif
            
            .popover(isPresented: $showPopover) {
                RecipeFieldListView()
            }
            .sheet(isPresented: $showingRecipeFields) {
                RecipeFieldListView()
                    .frame(minWidth: 400, minHeight: 600)
            }
        }
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

// Preview Provider für SwiftUI-Vorschau
#Preview {
    AddRecipeView()
//        .modelContainer(for: Recipe.self, inMemory: true)
}
