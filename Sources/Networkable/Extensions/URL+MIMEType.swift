#if os(iOS) || os(watchOS) || os(tvOS)
import MobileCoreServices
#elseif os(macOS)
import CoreServices
#endif
import Foundation

extension URL {
    /// Return a string re-presents the media type of the file localed at this URL,  (also known as a Multipurpose Internet Mail Extensions or MIME type)
    /// which is a standard that indicates the nature and format of a document, file, or assortment of bytes.
    /// https://www.iana.org/assignments/media-types/media-types.xhtml
    /// - Returns: A MIME type string.
    func mimeType() -> String? {
        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(
                kUTTagClassFilenameExtension,
                pathExtension as NSString,
                nil)?
                .takeRetainedValue(),
            let mimetype = UTTypeCopyPreferredTagWithClass(
                uti,
                kUTTagClassMIMEType)?
                .takeRetainedValue()
        else {
            return nil
        }
        return mimetype as String
    }
}
