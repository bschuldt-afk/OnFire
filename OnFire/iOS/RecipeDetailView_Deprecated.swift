//
//  ReceipeDetailView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 18.12.24.
//

import SwiftUI
import CookInSwift

struct RecipeDetailView_Deprecated: View {
    @Bindable var recipeModel: RecipeModel
    
    @State var isEditing: Bool = false
//    @State private var isExporting = false
    
    @StateObject private var exportManager = RecipeExportManager()
    
    var recipe = try! Recipe.from(text: "")
    
    init(recipeModel: RecipeModel, recipe: Recipe = try! Recipe.from(text: "")) {
        self.recipe = try! Recipe.from(text: recipeModel.content)
        self.recipeModel = recipeModel
    }
    
    // Diese Funktion extrahiert den reinen Text aus einem DirectionItem
    func getDirectionText(_ direction: DirectionItem) -> String {
        // Entfernt unerwünschte Formatierung und gibt den reinen Text zurück
        return direction.description
            .trimmingCharacters(in: .whitespaces)
    }
    
    // Kombiniert alle DirectionItems zu einem sauberen, lesbaren Text
    func combineDirections(_ directions: [DirectionItem]) -> String {
        // Konvertiert jedes DirectionItem in seinen reinen Text
        let textParts = directions.map { getDirectionText($0) }
        
        // Kombiniert die Textteile zu einem Satz
        let combinedText = textParts.joined(separator: " ")
        
        // Bereinigt den Text von mehrfachen Leerzeichen und formatiert ihn
        return formatDirection(combinedText)
    }
    
    // Formatiert den kombinierten Text für bessere Lesbarkeit
    func formatDirection(_ text: String) -> String {
        var formattedText = text
            // Entfernt mehrfache Leerzeichen
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            // Entfernt Leerzeichen vor Punkten
            .replacingOccurrences(of: "\\s+\\.", with: ".", options: .regularExpression)
            // Entfernt Leerzeichen vor Kommas
            .replacingOccurrences(of: "\\s+,", with: ",", options: .regularExpression)
            // Fügt Leerzeichen nach Kommas ein
            .replacingOccurrences(of: ",(?!\\s)", with: ", ", options: .regularExpression)
            // Fügt Leerzeichen nach Punkten ein
            .replacingOccurrences(of: "\\.(?!\\s|$)", with: ". ", options: .regularExpression)
        
        // Abschließende Bereinigung von Whitespace
        formattedText = formattedText.trimmingCharacters(in: .whitespaces)
        
        return formattedText
    }
    
    func formatMetadataValue(_ value: String) -> String {
        if let numericValue = Double(value) {
            return String(format: "%.1f", numericValue)
        }
        return value
    }
    
    var body: some View {
        List {
            ScrollView {
                Section {
                    ForEach(Array(recipe.metadata), id: \.key) { key, value in
                        HStack {
                            Text("\(key)")
                                .bold()
                            Spacer()
                            Text(formatMetadataValue(value))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    HStack {
                        Text("\(recipeModel.title)")
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                }
                
                Divider()
                
                Section {
                    ForEach(Array(recipe.ingredientsTable.ingredients), id: \.key) { key, value in
                        HStack {
                            Text("\(key)")
                                .bold()
                            Spacer()
                            Text("\(value)")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 1)
                    }
                } header: {
                    Text("Zutatenliste")
                        .font(.title)
                }
                
                Divider()
                
                Section {
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Step \(index + 1)")
                                    .font(.headline)
                                    .padding(.top, 8)
                                Spacer()
                            }
                            // Verwendet die neue Methode für die Directions
                            Text(combineDirections(step.directions))
                                .padding(.vertical, 2)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Zutaten für diesen Schritt
                            if !step.ingredientsTable.ingredients.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Ingredients for this step:")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 4)
                                    
                                    ForEach(Array(step.ingredientsTable.ingredients), id: \.key) { key, value in
                                        HStack {
                                            Text("•")
                                            Text("\(key)")
                                            Text("\(value)")
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.leading, 8)
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
        }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Edit") {
                    EditRecipeView(recipe: recipeModel)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                ExportButton(recipe: recipeModel, manager: exportManager)
            }
        }
        .recipeExporter(using: exportManager)
        #endif
    }
}

// Ein separater Export-Button für bessere Übersichtlichkeit
struct ExportButton: View {
    let recipe: RecipeModel
    @ObservedObject var manager: RecipeExportManager
    
    var body: some View {
        Button {
            
            manager.exportRecipe(recipe)
        } label: {
            Label("Exportieren", systemImage: "square.and.arrow.up")
        }
    }
}

#Preview {
    let rezept = RecipeModel(title: "Lachquatsch", content: """
>> title: Lachs im Frontmatter
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
    NavigationStack {
        RecipeDetailView_Deprecated(recipeModel: rezept)
    }
}
