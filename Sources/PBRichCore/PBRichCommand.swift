import AppKit
import ArgumentParser
import Foundation

public struct PBRichCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "pbrich",
        abstract: "Copy to macOS pasteboard with support for arbitrary types.",
        version: "1.1.0"
    )

    @Option(name: .shortAndLong, help: "Pasteboard type UTI (can be specified multiple times). Auto-detected from content if omitted.")
    public var type: [String] = []

    @Option(name: .shortAndLong, help: "Plain text fallback to set alongside the specified type(s).")
    public var plain: String?

    @Option(name: .shortAndLong, help: "Copy file reference(s) to clipboard (like Cmd+C in Finder). Can be repeated.")
    public var file: [String] = []

    @Flag(name: .shortAndLong, help: "List common pasteboard types.")
    public var listTypes = false

    public static var pasteboard: PasteboardWriter = SystemPasteboardWriter()
    public static var inputReader: () -> Data = {
        FileHandle.standardInput.readDataToEndOfFile()
    }

    public init() {}

    public func validate() throws {
        if !file.isEmpty && !type.isEmpty {
            throw ValidationError("--file cannot be combined with --type.")
        }
    }

    public func run() throws {
        if listTypes {
            printTypes()
            return
        }

        if !file.isEmpty {
            try copyFileReferences()
            return
        }

        let data = Self.inputReader()

        let types: [NSPasteboard.PasteboardType]
        if type.isEmpty {
            types = [Self.detectType(from: data)]
        } else {
            types = type.map { NSPasteboard.PasteboardType($0) }
        }

        var allTypes = types
        if plain != nil, !allTypes.contains(.string) {
            allTypes.append(.string)
        }

        let pb = Self.pasteboard
        pb.clearContents()
        pb.declareTypes(allTypes)

        for t in types {
            _ = pb.setData(data, forType: t)
        }

        if let plain {
            _ = pb.setString(plain, forType: .string)
        }
    }

    private func copyFileReferences() throws {
        let fm = FileManager.default
        var urls: [NSURL] = []

        for path in file {
            let resolved = NSString(string: path).expandingTildeInPath
            let absolute =
                resolved.hasPrefix("/")
                ? resolved
                : fm.currentDirectoryPath + "/" + resolved
            guard fm.fileExists(atPath: absolute) else {
                throw ValidationError("File not found: \(path)")
            }
            urls.append(NSURL(fileURLWithPath: absolute))
        }

        let pb = Self.pasteboard
        pb.clearContents()
        pb.writeObjects(urls)

        if let plain {
            _ = pb.setString(plain, forType: .string)
        }
    }

    static func detectType(from data: Data) -> NSPasteboard.PasteboardType {
        guard data.count >= 4 else { return .string }

        let bytes = [UInt8](data.prefix(8))

        // PNG: 89 50 4E 47
        if bytes.count >= 4, bytes[0] == 0x89, bytes[1] == 0x50, bytes[2] == 0x4E, bytes[3] == 0x47 {
            return .png
        }
        // JPEG: FF D8 FF
        if bytes.count >= 3, bytes[0] == 0xFF, bytes[1] == 0xD8, bytes[2] == 0xFF {
            return NSPasteboard.PasteboardType("public.jpeg")
        }
        // PDF: %PDF
        if bytes.count >= 4, bytes[0] == 0x25, bytes[1] == 0x50, bytes[2] == 0x44, bytes[3] == 0x46 {
            return NSPasteboard.PasteboardType("com.adobe.pdf")
        }
        // TIFF: 49 49 2A 00 (little-endian) or 4D 4D 00 2A (big-endian)
        if bytes.count >= 4 {
            if bytes[0] == 0x49, bytes[1] == 0x49, bytes[2] == 0x2A, bytes[3] == 0x00 { return .tiff }
            if bytes[0] == 0x4D, bytes[1] == 0x4D, bytes[2] == 0x00, bytes[3] == 0x2A { return .tiff }
        }
        // RTF: {\rtf
        if bytes.count >= 5, bytes[0] == 0x7B, bytes[1] == 0x5C, bytes[2] == 0x72, bytes[3] == 0x74,
            bytes[4] == 0x66
        {
            return .rtf
        }

        return .string
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
