//
//  IngredienCard.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 25.12.24.
//

import SwiftUI
import CookInSwift


struct IngredientCard: View {
    
    var step: Step
    
    var body: some View {
        
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
        .padding(.bottom, 4)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
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
    
    
 
    
    IngredientCard(step: recipe.parsedRecipe!.steps[1])
}
