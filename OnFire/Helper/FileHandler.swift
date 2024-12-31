//
//  FileHandler.swift
//  cooklang-claude
//
//  Created by Bjoern Schuldt on 26.12.24.
//
#if os(macOS)
import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// We keep the original FileHandlingState as it was working
@Observable class FileHandlingState {
    var isExporting = false
    var isImporting = false
    var exportData: ExportData?
    
    static let shared = FileHandlingState()
    private init() {}
}

struct ExportData: Codable {
    let filename: String
    let content: String
}

@Observable class FileHandler {
    static let shared = FileHandler()
    let state = FileHandlingState.shared
    static let cookType = UTType(exportedAs: "com.knibbelknabbel.cook", conformingTo: .text)
    
    private init() {}
    
    func exportAllRecipes(_ recipes: [RecipeModel]) {
        guard !recipes.isEmpty else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "zip")!]
        panel.nameFieldStringValue = "recipes_export.zip"
        
        panel.beginSheetModal(for: NSApp.keyWindow!) { response in
            if response == .OK {
                guard let exportURL = panel.url else { return }
                self.createArchive(with: recipes, at: exportURL)
            }
        }
    }
    
    private func createArchive(with recipes: [RecipeModel], at destinationURL: URL) {
        do {
            // Create a directory wrapper to hold all our files
            var recipeWrappers: [String: FileWrapper] = [:]
            
            // Create individual file wrappers for each recipe
            for recipe in recipes {
                let filename = sanitizeFilename(recipe.title) + ".cook"
                let data = recipe.content.data(using: .utf8)!
                let wrapper = FileWrapper(regularFileWithContents: data)
                wrapper.preferredFilename = filename
                recipeWrappers[filename] = wrapper
            }
            
            // Create metadata
            let metadata = createMetadata(for: recipes)
            let metadataData = try JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted)
            let metadataWrapper = FileWrapper(regularFileWithContents: metadataData)
            metadataWrapper.preferredFilename = "metadata.json"
            recipeWrappers["metadata.json"] = metadataWrapper
            
            // Create the directory wrapper containing all files
            let directoryWrapper = FileWrapper(directoryWithFileWrappers: recipeWrappers)
            
            // Write the archive
            try directoryWrapper.write(
                to: destinationURL,
                options: .atomic,
                originalContentsURL: nil
            )
            
            showSuccess("Recipes successfully exported to:\n\(destinationURL.path)")
            
        } catch {
            showError("Failed to create archive: \(error.localizedDescription)")
        }
    }
    
    private func createMetadata(for recipes: [RecipeModel]) -> [String: Any] {
        return [
            "exportInfo": [
                "exportDate": ISO8601DateFormatter().string(from: Date()),
                "totalRecipes": recipes.count,
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
            ],
            "recipes": recipes.map { recipe in
                [
                    "title": recipe.title,
                    "filename": "\(sanitizeFilename(recipe.title)).cook"
                ]
            }
        ]
    }
    
    private func sanitizeFilename(_ filename: String) -> String {
        let illegalCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        let components = filename.components(separatedBy: illegalCharacters)
        return components.joined(separator: "-")
    }
    
    private func showSuccess(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Export Successful"
            alert.informativeText = message
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Export Error"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    // Single recipe export remains the same
    func prepareExport(recipeModel: RecipeModel) {
        let safeFilename = recipeModel.title
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
        
        state.exportData = ExportData(
            filename: safeFilename,
            content: recipeModel.content
        )
        state.isExporting = true
    }
    
    private func performExport(recipes: [RecipeModel], to exportURL: URL) {
        do {
            // Create a temporary directory with a unique name
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("recipes_export_\(UUID().uuidString)")
            
            // Create the directory and its parent directories if needed
            try FileManager.default.createDirectory(
                at: tempDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            // Save recipes as individual files
            for recipe in recipes {
                let filename = recipe.title
                    .replacingOccurrences(of: "/", with: "-")
                    .replacingOccurrences(of: "\\", with: "-")
                    .replacingOccurrences(of: " ", with: "_")
                    .appending(".cook")
                
                let fileURL = tempDir.appendingPathComponent(filename)
                try recipe.content.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            
            // If a file already exists at the export location, remove it
            if FileManager.default.fileExists(atPath: exportURL.path) {
                try FileManager.default.removeItem(at: exportURL)
            }
            
            // Create ZIP with improved error handling
            try createZIPWithErrorHandling(at: exportURL, sourceDirectory: tempDir)
            
            // Verify the ZIP file was created
            if FileManager.default.fileExists(atPath: exportURL.path) {
                showSuccess()
            } else {
                showError("ZIP file was not created")
            }
            
            // Cleanup temporary directory
            try FileManager.default.removeItem(at: tempDir)
            
        } catch {
            showError("Export failed: \(error.localizedDescription)")
        }
    }
    
    private func createZIPWithErrorHandling(at destinationURL: URL, sourceDirectory: URL) throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        
        // Enhanced zip arguments:
        // -r: recursive
        // -y: store symbolic links
        // -q: quiet operation (less verbose)
        // -X: no extra file attributes
        task.arguments = [
            "-ryqX",
            destinationURL.path,
            "."  // Current directory
        ]
        
        // Set the working directory to our source directory
        task.currentDirectoryURL = sourceDirectory
        
        // Create pipes for both standard output and error
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                // Read error output if available
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                
                // Read standard output if available
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: outputData, encoding: .utf8) ?? "No output"
                
                // Create detailed error message
                let errorMessage = """
                    ZIP creation failed:
                    Exit code: \(task.terminationStatus)
                    Error output: \(errorOutput)
                    Standard output: \(output)
                    """
                
                throw NSError(
                    domain: "FileHandler",
                    code: Int(task.terminationStatus),
                    userInfo: [NSLocalizedDescriptionKey: errorMessage]
                )
            }
        } catch {
            throw error
        }
    }
    
    private func createZIP(at destinationURL: URL, sourceDirectory: URL) throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        task.arguments = ["-r", destinationURL.path, "."]
        task.currentDirectoryURL = sourceDirectory
        
        try task.run()
        task.waitUntilExit()
        
        if task.terminationStatus != 0 {
            throw NSError(domain: "FileHandler",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "ZIP creation failed"])
        }
    }
    
    private func showSuccess() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Export Successful"
            alert.informativeText = "All recipes have been exported successfully."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    // We'll use the existing state for importing
    func initiateImport() {
        state.isImporting = true
    }
    
    func importRecipe(from url: URL, modelContext: ModelContext) {
        guard url.startAccessingSecurityScopedResource() else {
            print("Access to file not possible")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let filename = url.deletingPathExtension().lastPathComponent
            
            let newRecipe = RecipeModel(
                title: filename,
                content: content
            )
            
            modelContext.insert(newRecipe)
            try modelContext.save()
            
            showSuccess("Recipe successfully imported: \(filename)")
            
        } catch {
            showError("Error importing recipe: \(error.localizedDescription)")
        }
    }
    
}

// The ViewModifier remains largely the same
struct FileHandlingViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    let state = FileHandlingState.shared
    let handler = FileHandler.shared
    
    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: .init(
                    get: { state.isImporting },
                    set: { state.isImporting = $0 }
                ),
                allowedContentTypes: [FileHandler.cookType],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let selectedFile = urls.first else { return }
                    handler.importRecipe(from: selectedFile, modelContext: modelContext)
                case .failure(let error):
                    print("Import error: \(error)")
                }
            }
            .fileExporter(
                isPresented: .init(
                    get: { state.isExporting },
                    set: { state.isExporting = $0 }
                ),
                document: state.exportData.map { data in
                    CookDocument(content: data.content)
                },
                contentType: FileHandler.cookType,
                defaultFilename: "\(state.exportData?.filename ?? "recipe").cook"
            ) { result in
                switch result {
                case .success(let url):
                    print("Successfully exported: \(url)")
                case .failure(let error):
                    print("Export error: \(error)")
                }
            }
    }
}

extension View {
    func withFileHandling() -> some View {
        modifier(FileHandlingViewModifier())
    }
}
#endif
