//
//  MacEditRecipeView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 23.12.24.
//

import SwiftUI
import SwiftData

struct MacEditRecipeView: View {
    // Umgebungsvariablen
    @Environment(\.dismiss) private var dismiss
    
    // Das zu bearbeitende Rezept als Bindable, damit Änderungen direkt gespeichert werden
    @Bindable var recipe: RecipeModel
    
    // State-Variablen für temporäre Änderungen
    @State private var editedTitle: String
    @State private var editedContent: String
    
    @State private var showPopover = false
    @State private var showingRecipeFields = false
    
    // Initialisierung mit den bestehenden Werten
    init(recipe: RecipeModel) {
        self.recipe = recipe
        // Initialisiere State-Variablen mit den aktuellen Werten
        _editedTitle = State(initialValue: recipe.title)
        _editedContent = State(initialValue: recipe.content)
    }
    
    var body: some View {
        #if os(macOS)
        HSplitView {
            HStack {
                VStack {
                    ScrollView {
                        TextField("Titel eingeben", text: $editedTitle)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        
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
                        
                        TextEditor(text: $editedContent)
                        
                            .frame(minHeight: 400, idealHeight: 550, maxHeight: .infinity)
                            .font(.system(.body, design: .monospaced))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.secondary, lineWidth: 1).opacity(0.2)
                            }
                            .padding()
                    }
                    
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
                        
                        Button("Speichern") {
                            saveRecipe()
                        }
                    }
                    .padding()
                }
                .frame(minWidth: 400)
                
                if showingRecipeFields {
                    MacRecipeFieldListView()
                        .frame(maxWidth: 300)
                }
            }
        }
#endif
    }
    
    private func saveRecipe() {
        // Aktualisiere das Rezept mit den bearbeiteten Werten
        recipe.title = editedTitle
        recipe.content = editedContent
        dismiss()
    }
}

#Preview {
    let recipe = RecipeModel(
        title: "Lachs mit Gedöns",
        content: """
>> servings: 1
>> produce: 300 g
>> calories: 411 kkal
>> protein: 41 g
>> total fat: 22 g
>> total carb.: 6.3 g

Preheat the oven to 180 degrees.

Cut a rectangular piece of #parchment or baking paper. Wash the @courgette{50%g} and cut into 5 mm thick rounds. Place on the parchment, drizzle with olive oil and season with @salt{1/3%tsp}  @pepper and chopped @thyme{1/5%tsp}.

Place the @salmon steak{200%g} on top and season the fish with @salt. Wrap the salmon and courgettes in the parchment to prevent drying out and place in the oven to bake for ~{15%minutes}.

While the fish is baking, make the sauce. Heat the @double cream{50%g}, @horseradish{10%g} and @salt in a #saucepan and simmer until thickened. Taste for further seasoning.

Place the fish and courgettes on a plate, spoon the sauce over the top and garnish with the @cherry tomatoes{30%g} cut in half and a @lemon{1%slice} wedge.
""")
    
    MacEditRecipeView(recipe: recipe)
}
