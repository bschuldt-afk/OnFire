//
//  StepCard.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 29.12.24.
//

import SwiftUI
import CookInSwift


struct StepCard: View {
    let step: Step
    let index: Int
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Schritt-Header
            HStack {
                Text("Schritt \(index + 1)")
                    .font(.headline)
                    .foregroundStyle(Color("TypoWhite"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .background(
                Color("Beilage")
                    .darker(by: Double(index) * 0.1, colorScheme: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Anweisungen
            Text(combineDirections(step.directions))
                .lineSpacing(4)
            
            // Zutaten für diesen Schritt
            if !step.ingredientsTable.ingredients.isEmpty {
                IngredientCard(step: step)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
    
    // Kombiniert alle DirectionItems zu einem sauberen, lesbaren Text
    func combineDirections(_ directions: [DirectionItem]) -> String {
        let textParts = directions.map { getDirectionText($0) }
        let combinedText = textParts.joined(separator: " ")
        return formatDirection(combinedText)
    }
    
    // Formatiert den kombinierten Text für bessere Lesbarkeit
    func formatDirection(_ text: String) -> String {
        var formattedText = text
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+\\.", with: ".", options: .regularExpression)
            .replacingOccurrences(of: "\\s+,", with: ",", options: .regularExpression)
            .replacingOccurrences(of: ",(?!\\s)", with: ", ", options: .regularExpression)
            .replacingOccurrences(of: "\\.(?!\\s|$)", with: ". ", options: .regularExpression)
        
        formattedText = formattedText.trimmingCharacters(in: .whitespaces)
        return formattedText
    }
    
    // Hilfsfunktionen für die Textverarbeitung
    func getDirectionText(_ direction: DirectionItem) -> String {
        return direction.description
            .trimmingCharacters(in: .whitespaces)
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
    
    let recipe = try! Recipe.from(text: rezept.content)
    
    StepCard(step: recipe.steps[1], index: 1, colorScheme: .dark)
}
