import AppKit
import ArgumentParser
import Foundation

@main
struct PBRich: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pbrich",
        abstract: "Copy to macOS pasteboard with support for arbitrary types.",
        version: "1.0.0"
    )

    @Option(name: .shortAndLong, help: "Pasteboard type UTI (can be specified multiple times).")
    var type: [String] = []

    @Option(name: .shortAndLong, help: "Plain text fallback to set alongside the specified type(s).")
    var plain: String?

    @Flag(name: .shortAndLong, help: "List common pasteboard types.")
    var listTypes = false

    func validate() throws {
        if plain != nil && type.isEmpty {
            throw ValidationError("--plain requires at least one --type")
        }
    }

    func run() throws {
        if listTypes {
            printTypes()
            return
        }

        let data = FileHandle.standardInput.readDataToEndOfFile()

        let types: [NSPasteboard.PasteboardType]
        if type.isEmpty {
            types = [.string]
        } else {
            types = type.map { NSPasteboard.PasteboardType($0) }
        }

        var allTypes = types
        if plain != nil, !allTypes.contains(.string) {
            allTypes.append(.string)
        }

        let pb = NSPasteboard.general
        pb.clearContents()
        pb.declareTypes(allTypes, owner: nil)

        for t in types {
            pb.setData(data, forType: t)
        }

        if let plain {
            pb.setString(plain, forType: .string)
        }
    }

    private func printTypes() {
        let types: [(String, String)] = [
            ("public.utf8-plain-text", "Plain text (default)"),
            ("public.html", "HTML content"),
            ("public.rtf", "Rich Text Format"),
            ("public.url", "URL"),
            ("public.file-url", "File URL"),
            ("public.png", "PNG image"),
            ("public.jpeg", "JPEG image"),
            ("public.tiff", "TIFF image"),
            ("com.adobe.pdf", "PDF document"),
            ("public.xml", "XML"),
            ("public.json", "JSON"),
        ]

        for (uti, desc) in types {
            print("  \(uti.padding(toLength: 28, withPad: " ", startingAt: 0)) \(desc)")
        }
    }
}
