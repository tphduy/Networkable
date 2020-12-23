import XCTest
@testable import Networkable

final class URL_MIMEType_Tests: XCTestCase {
    
    func testMIMEType_whenTypeIsApplication() throws {
        XCTAssertEqual(
            URL(string: "file:///foo/file.json")!
                .mimeType(),
            "application/json")
        
        XCTAssertEqual(
            URL(string: "file:///foo/file.pdf")!
                .mimeType(),
            "application/pdf")
        
        XCTAssertEqual(
            URL(string: "file:///foo/file.zip")!
                .mimeType(),
            "application/zip")
    }
    
    func testMIMEType_whenTypeIsAudio() throws {
        XCTAssertEqual(
            URL(string: "file:///foo/file.wav")!
                .mimeType(),
            "audio/vnd.wave")
            
        XCTAssertEqual(
            URL(string: "file:///foo/file.aac")!
                .mimeType(),
            "audio/aac")
        
        XCTAssertEqual(
            URL(string: "file:///foo/file.flac")!
                .mimeType(),
            "audio/flac")
    }
    
    func testMIMEType_whenTypeIsImage() throws {
        XCTAssertEqual(
            URL(string: "file:///foo/file.jpeg")!
                .mimeType(),
            "image/jpeg")
        
        XCTAssertEqual(
            URL(string: "file:///foo/file.png")!
                .mimeType(),
            "image/png")
        
        XCTAssertEqual(
            URL(string: "file:///foo/file.heic")!
                .mimeType(),
            "image/heic")
        
        XCTAssertEqual(
            URL(string: "file:///foo/file.svg")!
                .mimeType(),
            "image/svg+xml")
    }
    
    func testMIMEType_whenTypeIsVideo() throws {
        XCTAssertEqual(
            URL(string: "file:///foo/file.mp4")!
                .mimeType(),
            "video/mp4")
            
        XCTAssertEqual(
            URL(string: "file:///foo/file.mpeg")!
                .mimeType(),
            "video/mpeg")
        
        XCTAssertEqual(
            URL(string: "file:///foo/file.flv")!
                .mimeType(),
            "video/x-flv")
    }
    
    func testMIMEType_whenTypeIsUndefined() throws {
        XCTAssertNil(URL(string: "https://www.apple.com")?.mimeType())
        XCTAssertNil(URL(string: "file:///foo/file.foo")?.mimeType())
        XCTAssertNil(URL(string: "file:///foo/file.bar")?.mimeType())
        XCTAssertNil(URL(string: "file:///foo/file")?.mimeType())
    }
}
