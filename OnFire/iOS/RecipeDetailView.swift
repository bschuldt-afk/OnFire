//
//  DetailView.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 30.12.24.
//

#if os(iOS)
import SwiftUI
import CookInSwift


struct RecipeDetailView: View {
    @Bindable var recipe: RecipeModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header mit Titel und Metadaten
                VStack(alignment: .leading, spacing: 16) {
                    Text(recipe.title)
                        .font(.largeTitle)
                        .bold()
                    
                    
                    // Metadaten in einem Grid
                    if let metadata = recipe.parsedRecipe?.metadata {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(Array(metadata).sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                MetadataCard(key: key, value: value)
                            }
                        }
                    }
                }
                .padding()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("Beilage"))
                    .frame(height: 20)
                    .padding(.horizontal)
                
                // Hauptbild mit Material-Hintergrund
//                if let mainImage = recipe.images["main"] {
//                    Image(uiImage: UIImage(data: mainImage)!)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(maxHeight: 300)
//                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 16)
//                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
//                        )
//                        .padding(.horizontal)
//                }
                
                // Zutaten-Sektion
                if let ingredients = recipe.parsedRecipe?.ingredientsTable.ingredients {
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(ingredients.enumerated()), id: \.1.key) { index, element in
                                
                                let (key, value) = element
                                HStack {
                                    Text("\(key)")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text("\(value)")
                                        .foregroundStyle(.secondary)
                                }
                                Divider()
                            }
                        }
                    } header: {
                        SectionHeader(title: "Zutaten", systemImage: "basket")
                    }
                    .padding(.horizontal, 32)
                }
                
                    
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("Beilage"))
                    .frame(height: 20)
                    .padding(.horizontal)
                
                // Schritte-Sektion
                if let steps = recipe.parsedRecipe?.steps {
                    Section {
                        VStack(spacing: 24) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                StepCards(step: step, stepNumber: index + 1)
                                
//                                if let stepImage = recipe.images["\(index)"] {
//                                    Image(data: stepImage)?
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(height: 200)
//                                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                                }
                            }
                        }
                    } header: {
                        SectionHeader(title: "Zubereitung", systemImage: "list.bullet")
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Hilfskomponenten
struct MetadataCard: View {
    let key: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.title2)
                .bold()
            Spacer()
        }
    }
}

struct StepCards: View {
    let step: Step
    let stepNumber: Int
    
    // Kombiniert alle DirectionItems zu einem sauberen, lesbaren Text
    func combineDirections(_ directions: [DirectionItem]) -> String {
        // Konvertiert jedes DirectionItem in seinen reinen Text
        let textParts = directions.map { getDirectionText($0) }
        
        // Kombiniert die Textteile zu einem Satz
        let combinedText = textParts.joined(separator: " ")
        
        // Bereinigt den Text von mehrfachen Leerzeichen und formatiert ihn
        return formatDirection(combinedText)
    }
    
    // Diese Funktion extrahiert den reinen Text aus einem DirectionItem
    func getDirectionText(_ direction: DirectionItem) -> String {
        // Entfernt unerwünschte Formatierung und gibt den reinen Text zurück
        return direction.description
            .trimmingCharacters(in: .whitespaces)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Schritt-Nummer
            HStack {
                Text("Schritt \(stepNumber)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            // Anweisungen
            Text(combineDirections(step.directions))
                .fixedSize(horizontal: false, vertical: true)
            
            // Zutaten für diesen Schritt
            if !step.ingredientsTable.ingredients.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Benötigte Zutaten:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    ForEach(Array(step.ingredientsTable.ingredients), id: \.key) { key, value in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                            Text("\(key)")
                            Spacer()
                            Text("\(value)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let recipe = RecipeModel(
        title: "Lachs im Frontmatter",
        content: """
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
        """
    )
    
    return RecipeDetailView(recipe: recipe)
}


#endif
