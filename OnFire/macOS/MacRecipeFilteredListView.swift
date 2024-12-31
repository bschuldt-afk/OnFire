//
//  MacRecipeFilteredListView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 25.12.24.
//

import SwiftUI
import SwiftData
import CookInSwift

struct MacRecipeFilteredListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [RecipeModel]
    @Binding var selection: RecipeModel?
    @State private var selectedCategory: String?
    
    private var filteredRecipes: [CategorySection] {
        let sections = categorizedRecipes
        guard let selectedCategory = selectedCategory else {
            return sections
        }
        return sections.filter { $0.name == selectedCategory }
    }
    
    // Popup für Kategorie bearbeiten
    @State private var showingCategoryEditor = false
    @State private var selectedRecipeForCategory: RecipeModel?
    @State private var editingCategory = ""
    
    // Computed property für kategorisierte Rezepte
    private var categorizedRecipes: [CategorySection] {
        let grouped = Dictionary(grouping: recipes) { recipe in
            recipe.category
        }
        
        return grouped.map { category, recipes in
            CategorySection(name: category, recipes: recipes)
        }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack {
            // Kategorie-Picker
            Picker("Kategorie", selection: $selectedCategory) {
                Text("Alle").tag(nil as String?)
                ForEach(categorizedRecipes) { section in
                    Text(section.name).tag(section.name as String?)
                }
            }
            .frame(height: 40)
            .pickerStyle(.menu)
            .padding(.horizontal)
            
            // Liste mit gefilterten Rezepten
            List(selection: $selection) {
                ForEach(filteredRecipes) { section in
                    Section(header: Text(section.name)) {
                        ForEach(section.recipes) { recipe in
                            NavigationLink(value: recipe) {
                                VStack(alignment: .leading) {
                                    Text(recipe.title)
                                        .font(.headline)
                                    Text(recipe.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .contextMenu {
                                    Button("Kategorie bearbeiten") {
                                        selectedRecipeForCategory = recipe
                                        editingCategory = recipe.category
                                        showingCategoryEditor = true
                                    }
                                    
                                    Button("Löschen") {
                                        modelContext.delete(recipe)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .popover(isPresented: $showingCategoryEditor) {
                VStack {
                    TextField("Kategorie", text: $editingCategory)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    HStack {
                        Button("Abbrechen") {
                            showingCategoryEditor = false
                        }
                        Button("Speichern") {
                            if let recipe = selectedRecipeForCategory {
                                recipe.category = editingCategory
                            }
                            showingCategoryEditor = false
                        }
                    }
                    .padding()
                }
                .frame(width: 300)
                .padding()
            }
        }
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
    
    MacRecipeFilteredListView(selection: .constant(recipe))
}
