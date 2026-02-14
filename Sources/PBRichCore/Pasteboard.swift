import AppKit

public protocol PasteboardWriter {
    func clearContents()
    func declareTypes(_ types: [NSPasteboard.PasteboardType])
    @discardableResult func setData(_ data: Data, forType type: NSPasteboard.PasteboardType) -> Bool
    @discardableResult func setString(_ string: String, forType type: NSPasteboard.PasteboardType) -> Bool
}

public struct SystemPasteboardWriter: PasteboardWriter {
    private let pb: NSPasteboard

    public init(_ pb: NSPasteboard = .general) {
        self.pb = pb
    }

    public func clearContents() {
        pb.clearContents()
    }

    public func declareTypes(_ types: [NSPasteboard.PasteboardType]) {
        pb.declareTypes(types, owner: nil)
    }

    public func setData(_ data: Data, forType type: NSPasteboard.PasteboardType) -> Bool {
        pb.setData(data, forType: type)
    }

    public func setString(_ string: String, forType type: NSPasteboard.PasteboardType) -> Bool {
        pb.setString(string, forType: type)
    }
}
