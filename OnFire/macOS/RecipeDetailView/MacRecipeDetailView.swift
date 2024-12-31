//
//  ReceipeDetailView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 18.12.24.
//
#if os(macOS)
import SwiftUI
import CookInSwift
import Observation

@Observable class RecipeDetailState {
    var isEditing = false
    var editedTitle: String
    var editedContent: String
    
    init(recipe: RecipeModel) {
        self.editedTitle = recipe.title
        self.editedContent = recipe.content
    }
}

struct MacRecipeDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let fileHandler = FileHandler.shared
    @State private var viewState: RecipeDetailState
    
    @Bindable var recipeModel: RecipeModel
    
    @State var isEditing: Bool = false
    @State private var showMetadata: Bool = false
    @State private var showIngredients: Bool = false
    
    var recipe = try! Recipe.from(text: "")
    
    init(recipeModel: RecipeModel, recipe: Recipe = try! Recipe.from(text: "")) {
        self.recipe = try! Recipe.from(text: recipeModel.content)
        self.recipeModel = recipeModel
        _viewState = State(initialValue: RecipeDetailState(recipe: recipeModel))
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
        Group {
            ScrollView(.vertical) {
                Rectangle()
                    .fill(recipeModel.category == "Beilage" ? Color.blue : Color.red)
                    .frame(height: 16)
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        // Titel
                        HStack {
                            Text(recipeModel.title)
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.medium)
                            Spacer()
                            MetadataToggleButton(showMetadata: $showMetadata)
                        }
                        
                        if !showMetadata {
                            // Metadata Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(Array(recipe.metadata).sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                    MetadataRow(key: key, value: formatMetadataValue(value))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Zutaten
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Zutaten")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.medium)
                            Spacer()
                            IngredientsToggleButton(showIngredients: $showIngredients)
                        }
                        
                        if !showIngredients {
                            VStack(spacing: 8) {
                                ForEach(Array(recipe.ingredientsTable.ingredients.sorted { $0.key < $1.key }.enumerated()), id: \.1.key) { index, element in

                                    let (key, value) = element

                                    IngredientRow(
                                        name: "\(key)",
                                        amount: "\(value)",//formatIngredientAmount(element.value),
                                        isEven: index.isMultiple(of: 2)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Rectangle()
                    .fill(recipeModel.category == "Beilage" ? Color.blue : Color.red)
                    .frame(height: 16)
                
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Zubereitung")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.medium)
                        
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            StepCard(step: step, index: index, colorScheme: colorScheme)
                        }
                    }
                }
             
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 300)
                
            }
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        MacEditRecipeView(recipe: recipeModel)
                    } label: {
                        Label("Bearbeiten", systemImage: "pencil")
                            .labelStyle(.titleAndIcon)
                    }
                }
                
                ToolbarItem {
                    Button {
                        fileHandler.prepareExport(recipeModel: recipeModel)
                    } label: {
                        Label("Exportieren", systemImage: "square.and.arrow.up")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .padding()
            
        }
        .withFileHandling()
        
    }
        
    // Hilfsfunktion zum Formatieren der Zutatenmenge
    func formatIngredientAmount(_ amount: IngredientAmountCollection) -> String {
        return amount.map { amount in
//        return amount.value.map { amount in
            if amount.units.isEmpty {
                return String(format: "%.1f", amount.description)
            } else {
                return String(format: "%.1f %@", amount.description, amount.units)
            }
        }.joined(separator: ", ")
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
>> category: Beilage
Preheat the oven to 180 degrees.

Cut a rectangular piece of #parchment or baking paper. Wash the @courgette{50%g} and cut into 5 mm thick rounds. Place on the parchment, drizzle with olive oil and season with @salt{1/3%tsp}  @pepper and chopped @thyme{1/5%tsp}.

Place the @salmon steak{200%g} on top and season the fish with @salt. Wrap the salmon and courgettes in the parchment to prevent drying out and place in the oven to bake for ~{15%minutes}.

While the fish is baking, make the sauce. Heat the @double cream{50%g}, @horseradish{10%g} and @salt in a #saucepan and simmer until thickened. Taste for further seasoning.

Place the fish and courgettes on a plate, spoon the sauce over the top and garnish with the @cherry tomatoes{30%g} cut in half and a @lemon{1%slice} wedge.
""")
    NavigationStack {
        MacRecipeDetailView(recipeModel: rezept)
    }
}
#endif

