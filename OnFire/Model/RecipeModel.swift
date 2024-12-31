//
//  RecipeModel.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 17.12.24.
//

import SwiftData
import Foundation
import CookInSwift
import ConfigParser

struct CategorySection: Identifiable {
    let id = UUID()
    let name: String
    let recipes: [RecipeModel]
}

@Model
class RecipeModel: Codable {
    
    enum CodingKeys: CodingKey {
        case title
        case content
        case timestamp
        case category
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(category, forKey: .category)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        category = try container.decode(String.self, forKey: .category)
    }
    
    var title: String
    var content: String
    var timestamp: Date
    
    var category: String {
          get {
              if let recipe = parsedRecipe,
                 let category = recipe.metadata["category"] {
                  return category
              }
              return "Unkategorisiert"
          }
          set {
              // Aktuellen Content parsen
              guard var recipe = parsedRecipe else { return }
              
              // Neue Kategorie in Metadaten setzen
              recipe.metadata["category"] = newValue
              
              // Content aktualisieren
              var contentLines = content.components(separatedBy: .newlines)
              
              // Suche nach existierender Kategorie-Zeile
              let categoryIndex = contentLines.firstIndex { line in
                  line.trimmingCharacters(in: .whitespaces).starts(with: ">> category:")
              }
              
              let categoryLine = ">> category: \(newValue)"
              
              if let index = categoryIndex {
                  // Existierende Kategorie aktualisieren
                  contentLines[index] = categoryLine
              } else {
                  // Neue Kategorie am Anfang einfügen, nach anderen Metadaten
                  let metadataEndIndex = contentLines.firstIndex { !$0.trimmingCharacters(in: .whitespaces).starts(with: ">>") } ?? 0
                  contentLines.insert(categoryLine, at: metadataEndIndex)
              }
              
              // Aktualisierter Content
              content = contentLines.joined(separator: "\n")
          }
      
    }

    
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.timestamp = Date()
    }
    
    // Konfigurierter Parser mit angepassten Einstellungen
    private var configuredParser: ConfigParser {
            get {
                // Beispiel für eine Konfigurationsdatei
                let configString = """
                step.start.delimiter =
                step.end.delimiter =
                block.tag.start = [
                block.tag.end = ]
                ingredient.tag.char = @
                cookware.tag.char = #
                timer.tag.char = ~
                """
        
                return ConfigParser(configString)
            }
        }

    // Parsed recipe mit konfiguriertem Parser
    var parsedRecipe: Recipe? {
        get {
            return try! Recipe.from(text: content)
        }
    }
}

// Preview helper für die Entwicklung
extension Recipe {
    static var preview: RecipeModel {
        RecipeModel(
            title: "Beispielrezept",
            content: """
            >> servings: 4
            
            Bringe @Wasser{1.5%l} zum Kochen. Füge @Spaghetti{500%g} hinzu und koche sie für #Zeit{10%minutes}.
            """
        )
    }
}
