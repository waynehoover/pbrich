import AppKit
@testable import PBRichCore

class MockPasteboard: PasteboardWriter {
    var cleared = false
    var declaredTypes: [NSPasteboard.PasteboardType] = []
    var dataEntries: [(Data, NSPasteboard.PasteboardType)] = []
    var stringEntries: [(String, NSPasteboard.PasteboardType)] = []

    func clearContents() {
        cleared = true
        declaredTypes = []
        dataEntries = []
        stringEntries = []
    }

    func declareTypes(_ types: [NSPasteboard.PasteboardType]) {
        declaredTypes = types
    }

    func setData(_ data: Data, forType type: NSPasteboard.PasteboardType) -> Bool {
        dataEntries.append((data, type))
        return true
    }

    func setString(_ string: String, forType type: NSPasteboard.PasteboardType) -> Bool {
        stringEntries.append((string, type))
        return true
    }
}
