import AppKit
import XCTest

@testable import PBRichCore

final class PBRichCommandTests: XCTestCase {
    var mock: MockPasteboard!

    override func setUp() {
        super.setUp()
        mock = MockPasteboard()
        PBRichCommand.pasteboard = mock
    }

    override func tearDown() {
        PBRichCommand.pasteboard = SystemPasteboardWriter()
        PBRichCommand.inputReader = { FileHandle.standardInput.readDataToEndOfFile() }
        super.tearDown()
    }

    // MARK: - Argument Parsing

    func testDefaultParsing() throws {
        let command = try PBRichCommand.parse([])
        XCTAssertTrue(command.type.isEmpty)
        XCTAssertNil(command.plain)
        XCTAssertFalse(command.listTypes)
    }

    func testSingleType() throws {
        let command = try PBRichCommand.parse(["-t", "public.html"])
        XCTAssertEqual(command.type, ["public.html"])
    }

    func testMultipleTypes() throws {
        let command = try PBRichCommand.parse(["-t", "public.html", "-t", "public.rtf"])
        XCTAssertEqual(command.type, ["public.html", "public.rtf"])
    }

    func testPlainFlag() throws {
        let command = try PBRichCommand.parse(["-t", "public.html", "-p", "fallback"])
        XCTAssertEqual(command.plain, "fallback")
    }

    func testListTypesFlag() throws {
        let command = try PBRichCommand.parse(["--list-types"])
        XCTAssertTrue(command.listTypes)
    }

    // MARK: - Type Detection

    func testDetectPNG() {
        let data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        XCTAssertEqual(PBRichCommand.detectType(from: data), .png)
    }

    func testDetectJPEG() {
        let data = Data([0xFF, 0xD8, 0xFF, 0xE0])
        XCTAssertEqual(PBRichCommand.detectType(from: data), NSPasteboard.PasteboardType("public.jpeg"))
    }

    func testDetectPDF() {
        let data = Data([0x25, 0x50, 0x44, 0x46, 0x2D])  // %PDF-
        XCTAssertEqual(PBRichCommand.detectType(from: data), NSPasteboard.PasteboardType("com.adobe.pdf"))
    }

    func testDetectTIFFLittleEndian() {
        let data = Data([0x49, 0x49, 0x2A, 0x00])
        XCTAssertEqual(PBRichCommand.detectType(from: data), .tiff)
    }

    func testDetectTIFFBigEndian() {
        let data = Data([0x4D, 0x4D, 0x00, 0x2A])
        XCTAssertEqual(PBRichCommand.detectType(from: data), .tiff)
    }

    func testDetectRTF() {
        let data = "{\\rtf1 hello}".data(using: .utf8)!
        XCTAssertEqual(PBRichCommand.detectType(from: data), .rtf)
    }

    func testDetectPlainText() {
        let data = "hello world".data(using: .utf8)!
        XCTAssertEqual(PBRichCommand.detectType(from: data), .string)
    }

    func testDetectShortData() {
        let data = Data([0x89, 0x50])
        XCTAssertEqual(PBRichCommand.detectType(from: data), .string)
    }

    func testDetectEmptyData() {
        XCTAssertEqual(PBRichCommand.detectType(from: Data()), .string)
    }

    // MARK: - Auto-Detection Integration

    func testAutoDetectsPNG() throws {
        let pngHeader = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00])
        PBRichCommand.inputReader = { pngHeader }

        let command = try PBRichCommand.parse([])
        try command.run()

        XCTAssertEqual(mock.declaredTypes, [.png])
        XCTAssertEqual(mock.dataEntries[0].1, .png)
    }

    func testExplicitTypeOverridesDetection() throws {
        let pngHeader = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        PBRichCommand.inputReader = { pngHeader }

        let command = try PBRichCommand.parse(["-t", "public.tiff"])
        try command.run()

        XCTAssertEqual(mock.declaredTypes, [.tiff])
    }

    // MARK: - Pasteboard Behavior

    func testDefaultCopiesAsPlainText() throws {
        PBRichCommand.inputReader = { "hello".data(using: .utf8)! }

        let command = try PBRichCommand.parse([])
        try command.run()

        XCTAssertTrue(mock.cleared)
        XCTAssertEqual(mock.declaredTypes, [.string])
        XCTAssertEqual(mock.dataEntries.count, 1)
        XCTAssertEqual(mock.dataEntries[0].1, .string)
        XCTAssertEqual(String(data: mock.dataEntries[0].0, encoding: .utf8), "hello")
    }

    func testCustomType() throws {
        let html = "<b>bold</b>"
        PBRichCommand.inputReader = { html.data(using: .utf8)! }

        let command = try PBRichCommand.parse(["-t", "public.html"])
        try command.run()

        XCTAssertEqual(mock.declaredTypes, [.html])
        XCTAssertEqual(mock.dataEntries.count, 1)
        XCTAssertEqual(mock.dataEntries[0].1, .html)
        XCTAssertEqual(String(data: mock.dataEntries[0].0, encoding: .utf8), html)
    }

    func testMultipleTypesSameContent() throws {
        PBRichCommand.inputReader = { "data".data(using: .utf8)! }

        let command = try PBRichCommand.parse(["-t", "public.html", "-t", "public.rtf"])
        try command.run()

        XCTAssertEqual(mock.declaredTypes, [.html, .rtf])
        XCTAssertEqual(mock.dataEntries.count, 2)
        XCTAssertEqual(mock.dataEntries[0].1, .html)
        XCTAssertEqual(mock.dataEntries[1].1, .rtf)
    }

    func testPlainTextFallback() throws {
        let html = "<a href=\"https://example.com\">Link</a>"
        PBRichCommand.inputReader = { html.data(using: .utf8)! }

        let command = try PBRichCommand.parse(["-t", "public.html", "-p", "https://example.com"])
        try command.run()

        XCTAssertTrue(mock.declaredTypes.contains(.html))
        XCTAssertTrue(mock.declaredTypes.contains(.string))

        XCTAssertEqual(mock.dataEntries.count, 1)
        XCTAssertEqual(mock.dataEntries[0].1, .html)

        XCTAssertEqual(mock.stringEntries.count, 1)
        XCTAssertEqual(mock.stringEntries[0].0, "https://example.com")
        XCTAssertEqual(mock.stringEntries[0].1, .string)
    }

    func testPlainDoesNotDuplicateStringType() throws {
        PBRichCommand.inputReader = { "data".data(using: .utf8)! }

        let command = try PBRichCommand.parse([
            "-t", "public.utf8-plain-text", "-t", "public.html", "-p", "fallback",
        ])
        try command.run()

        let stringCount = mock.declaredTypes.filter { $0 == .string }.count
        XCTAssertEqual(stringCount, 1)
    }

    func testEmptyInput() throws {
        PBRichCommand.inputReader = { Data() }

        let command = try PBRichCommand.parse([])
        try command.run()

        XCTAssertTrue(mock.cleared)
        XCTAssertEqual(mock.dataEntries.count, 1)
        XCTAssertTrue(mock.dataEntries[0].0.isEmpty)
    }
}
