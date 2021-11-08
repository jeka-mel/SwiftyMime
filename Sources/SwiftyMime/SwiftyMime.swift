import Foundation

// MARK: - File type categories

public enum ImageFileType: String, CaseIterable {
    case jpg, jpeg, png, gif, webp, flif, cr2, tif, bmp, jxr, psd, ico
}

public enum BinaryFileType: String, CaseIterable {
    case pdf, exe, swf, rtf, woff, woff2, eot, ttf, otf, ps, xz, sqlite, nes, crx, mxf
}

public enum ArchiveFileType: String, CaseIterable {
    case epub, xpi, zip, tar, rar, gz, gzip, bz2, dmg, cab, deb, rpm, ar, z, lz, msi
    case sevenZip
}

public enum VideoFileType: String, CaseIterable {
    case mp4, m4v, mkv, webm, mov, avi, mpg, flv, wmv
}

public enum AudioFileType: String, CaseIterable {
    case mid, mp3, m4a, opus, ogg, flac, wav, amr
}

// MARK: - SomeFileType

public enum FileTypeCategory {
    case image, audio, video, archive, binary, unknown
}

public protocol AnyKnownFileType {
    var ext: String { get }
    var category: FileTypeCategory { get }
}

public protocol SomeFileType: AnyKnownFileType, RawRepresentable { }

extension ImageFileType: SomeFileType {
    public var ext: String { rawValue }
    public var category: FileTypeCategory { .image }
}

extension BinaryFileType: SomeFileType {
    public var ext: String { rawValue }
    public var category: FileTypeCategory { .binary }
}

extension ArchiveFileType: SomeFileType {
    public var ext: String {
        switch self {
        case .sevenZip: return "7z"
        default: return rawValue
        }
    }

    public var category: FileTypeCategory { .archive }
}

extension VideoFileType: SomeFileType {
    public var ext: String { rawValue }
    public var category: FileTypeCategory { .video }
}

extension AudioFileType: SomeFileType {
    public var ext: String { rawValue }
    public var category: FileTypeCategory { .audio }
}

// MARK: - MimeTypeRepresentable

public protocol MimeTypeRepresentable {
    var mimeType: String { get }
}

extension ImageFileType: MimeTypeRepresentable {
    public var mimeType: String {
        switch self {
        case .cr2: return "image/x-canon-cr2"
        case .tif: return "image/tiff"
        case .jxr: return "image/vnd.ms-photo"
        case .psd: return "image/vnd.adobe.photoshop"
        case .ico: return "image/x-icon"
        default: return "image/\(rawValue)"
        }
    }
}

extension BinaryFileType: MimeTypeRepresentable {
    public var mimeType: String {
        switch self {
        case .exe: return "application/x-msdownload"
        case .swf: return "application/x-shockwave-flash"
        case .woff, .woff2: return "application/font-woff"
        case .eot: return "application/octet-stream"
        case .ttf, .otf: return "application/font-sfnt"
        case .ps: return "application/postscript"
        case .xz: return "application/x-xz"
        case .sqlite: return "application/x-sqlite3"
        case .nes: return "application/x-nintendo-nes-rom"
        case .crx: return "application/x-google-chrome-extension"
        default: return "application/\(rawValue)"
        }
    }
}

extension ArchiveFileType: MimeTypeRepresentable {
    public var mimeType: String {
        switch self {
        case .epub: return "application/epub+zip"
        case .xpi: return "application/x-xpinstall"
        case .tar: return "application/x-tar"
        case .rar: return "application/x-rar-compressed"
        case .gz, .gzip: return "application/gzip"
        case .bz2: return "application/x-bzip2"
        case .sevenZip: return "application/x-7z-compressed"
        case .dmg: return "application/x-apple-diskimage"
        case .cab: return "application/vnd.ms-cab-compressed"
        case .deb: return "application/x-deb"
        case .ar: return "application/x-unix-archive"
        case .rpm: return "application/x-rpm"
        case .z: return "application/x-compress"
        case .lz: return "application/x-lzip"
        case .msi: return "application/x-msi"
        default: return "application/\(rawValue)"
        }
    }
}

extension VideoFileType: MimeTypeRepresentable {
    public var mimeType: String {
        switch self {
        case .m4v: return "video/x-m4v"
        case .mkv: return "video/x-matroska"
        case .mov: return "video/quicktime"
        case .avi: return "video/x-msvideo"
        case .wmv: return "video/x-ms-wmv"
        case .flv: return "video/x-flv"
        default: return "video/\(rawValue)"
        }
    }
}

extension AudioFileType: MimeTypeRepresentable {
    public var mimeType: String {
        switch self {
        case .mid: return "audio/midi"
        case .mp3: return "audio/mpeg"
        case .flac: return "audio/x-flac"
        case .wav: return "audio/x-wav"
        default: return "audio/\(rawValue)"
        }
    }
}

// MARK: - ByteMatchable

public protocol ByteMatchable {
    /// Number of bytes required for `MimeType` to be able to check if the
    /// given bytes match with its mime type magic number specifications.
    var bytesCount: Int { get }

    /// A closure to check if the bytes match the `MimeType` specifications.
    var matches: ([UInt8], Data) -> Bool { get }
}

extension ImageFileType: ByteMatchable {

    public var bytesCount: Int {
        switch self {
        case .jpg, .jpeg, .gif, .jxr: return 3
        case .png, .flif, .tif, .psd, .ico: return 4
        case .webp: return 12
        case .cr2: return 10
        case .bmp: return 2
        }
    }

    public var matches: ([UInt8], Data) -> Bool {
        switch self {
        case .jpg, .jpeg: return { bytes, _ in
                bytes[0...2] == [0xFF, 0xD8, 0xFF]
            }
        case .png: return { bytes, _ in
                bytes[0...3] == [0x89, 0x50, 0x4E, 0x47]
            }
        case .gif: return { bytes, _ in
                bytes[0...2] == [0x47, 0x49, 0x46]
            }
        case .webp: return { bytes, _ in
                bytes[8...11] == [0x57, 0x45, 0x42, 0x50]
            }
        case .flif: return { bytes, _ in
                bytes[0...3] == [0x46, 0x4C, 0x49, 0x46]
            }
        case .cr2: return { bytes, _ in
                (bytes[0...3] == [0x49, 0x49, 0x2A, 0x00] || bytes[0...3] == [0x4D, 0x4D, 0x00, 0x2A]) &&
                    (bytes[8...9] == [0x43, 0x52])
            }
        case .tif: return { bytes, _ in
                (bytes[0...3] == [0x49, 0x49, 0x2A, 0x00]) ||
                    (bytes[0...3] == [0x4D, 0x4D, 0x00, 0x2A])
            }
        case .bmp: return { bytes, _ in
                bytes[0...1] == [0x42, 0x4D]
            }
        case .jxr: return { bytes, _ in
                bytes[0...2] == [0x49, 0x49, 0xBC]
            }
        case .psd: return { bytes, _ in
                bytes[0...3] == [0x38, 0x42, 0x50, 0x53]
            }
        case .ico: return { bytes, _ in
                bytes[0...3] == [0x00, 0x00, 0x01, 0x00]
            }
        }
    }
}

extension BinaryFileType: ByteMatchable {

    public var bytesCount: Int {
        switch self {
        case .pdf, .sqlite, .nes, .crx: return 4
        case .exe, .ps: return 2
        case .swf: return 3
        case .rtf, .ttf, .otf: return 5
        case .woff, .woff2: return 8
        case .eot: return 11
        case .xz: return 6
        case .mxf: return 14
        }
    }

    public var matches: ([UInt8], Data) -> Bool {
        switch self {
        case .pdf: return { bytes, _ in
                bytes[0...3] == [0x25, 0x50, 0x44, 0x46]
            }
        case .exe: return { bytes, _ in
                bytes[0...1] == [0x4D, 0x5A]
            }
        case .swf: return { bytes, _ in
                (bytes[0] == 0x43 || bytes[0] == 0x46) && (bytes[1...2] == [0x57, 0x53])
            }
        case .rtf: return { bytes, _ in
                bytes[0...4] == [0x7B, 0x5C, 0x72, 0x74, 0x66]
            }
        case .woff, .woff2: return { bytes, _ in
                (bytes[0...3] == [0x77, 0x4F, 0x46, 0x32]) &&
                    ((bytes[4...7] == [0x00, 0x01, 0x00, 0x00]) || (bytes[4...7] == [0x4F, 0x54, 0x54, 0x4F]))
            }
        case .eot: return { bytes, _ in
            guard bytesCount >= 35, bytes[34...35] == [0x4C, 0x50] else { return false }
            return ((bytes[8...10] == [0x00, 0x00, 0x01]) || (bytes[8...10] == [0x01, 0x00, 0x02]) || (bytes[8...10] == [0x02, 0x00, 0x02]))
            }
        case .ttf: return { bytes, _ in
                bytes[0...4] == [0x00, 0x01, 0x00, 0x00, 0x00]
            }
        case .otf: return { bytes, _ in
                bytes[0...4] == [0x4F, 0x54, 0x54, 0x4F, 0x00]
            }
        case .ps: return { bytes, _ in
                bytes[0...1] == [0x25, 0x21]
            }
        case .xz: return { bytes, _ in
                bytes[0...5] == [0xFD, 0x37, 0x7A, 0x58, 0x5A, 0x00]
            }
        case .sqlite: return { bytes, _ in
                bytes[0...3] == [0x53, 0x51, 0x4C, 0x69]
            }
        case .nes: return { bytes, _ in
                bytes[0...3] == [0x4E, 0x45, 0x53, 0x1A]
            }
        case .crx: return { bytes, _ in
                bytes[0...3] == [0x43, 0x72, 0x32, 0x34]
            }
        case .mxf: return { bytes, _ in
                bytes[0...13] == [0x06, 0x0E, 0x2B, 0x34, 0x02, 0x05, 0x01, 0x01, 0x0D, 0x01, 0x02, 0x01, 0x01, 0x02 ]
            }
        }
    }
}

extension ArchiveFileType: ByteMatchable {

    public var bytesCount: Int {
        switch self {
        case .epub: return 58
        case .xpi, .zip: return 50
        case .tar: return 262
        case .rar, .ar: return 7
        case .gz, .gzip, .bz2: return 3
        case .dmg, .z: return 2
        case .cab, .rpm, .lz: return 4
        case .deb: return 21
        case .msi: return 8
        case .sevenZip: return 6
        }
    }

    public var matches: ([UInt8], Data) -> Bool {
        switch self {
        case .epub: return { bytes, _ in
                (bytes[0...3] == [0x50, 0x4B, 0x03, 0x04]) &&
                    (bytes[30...57] == [
                        0x6D, 0x69, 0x6D, 0x65, 0x74, 0x79, 0x70, 0x65, 0x61, 0x70, 0x70, 0x6C,
                        0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E, 0x2F, 0x65, 0x70, 0x75, 0x62,
                        0x2B, 0x7A, 0x69, 0x70
                        ])
            }
        case .xpi: return { bytes, _ in
                (bytes[0...3] == [0x50, 0x4B, 0x03, 0x04]) &&
                    (bytes[30...49] == [
                        0x4D, 0x45, 0x54, 0x41, 0x2D, 0x49, 0x4E, 0x46, 0x2F, 0x6D, 0x6F, 0x7A,
                        0x69, 0x6C, 0x6C, 0x61, 0x2E, 0x72, 0x73, 0x61
                        ])
            }
        case .zip: return { bytes, _ in
            guard bytes[0...1] == [0x50, 0x4B] else { return false }
            guard bytes[2] == 0x3 || bytes[2] == 0x5 || bytes[2] == 0x7 else { return false }
            return (bytes[3] == 0x4 || bytes[3] == 0x6 || bytes[3] == 0x8)
            }
        case .tar: return { bytes, _ in
                bytes[257...261] == [0x75, 0x73, 0x74, 0x61, 0x72]
            }
        case .rar: return { bytes, _ in
                (bytes[0...5] == [0x52, 0x61, 0x72, 0x21, 0x1A, 0x07]) &&
                    (bytes[6] == 0x0 || bytes[6] == 0x1)
            }
        case .gz, .gzip: return { bytes, _ in
                bytes[0...2] == [0x1F, 0x8B, 0x08]
            }
        case .bz2: return { bytes, _ in
                bytes[0...2] == [0x42, 0x5A, 0x68]
            }
        case .dmg: return { bytes, _ in
                bytes[0...1] == [0x78, 0x01]
            }
        case .cab: return { bytes, _ in
                (bytes[0...3] == [0x4D, 0x53, 0x43, 0x46]) || (bytes[0...3] == [0x49, 0x53, 0x63, 0x28])
            }
        case .deb: return { bytes, _ in
                bytes[0...20] == [
                    0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E, 0x0A, 0x64, 0x65, 0x62, 0x69,
                    0x61, 0x6E, 0x2D, 0x62, 0x69, 0x6E, 0x61, 0x72, 0x79
                ]
            }
        case .rpm: return { bytes, _ in
                bytes[0...3] == [0xED, 0xAB, 0xEE, 0xDB]
            }
        case .ar: return { bytes, _ in
                bytes[0...6] == [0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E]
            }
        case .z: return { bytes, _ in
                (bytes[0...1] == [0x1F, 0xA0]) || (bytes[0...1] == [0x1F, 0x9D])
            }
        case .lz: return { bytes, _ in
                bytes[0...3] == [0x4C, 0x5A, 0x49, 0x50]
            }
        case .msi: return { bytes, _ in
                bytes[0...7] == [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1]
            }
        case .sevenZip: return { bytes, _ in
                bytes[0...5] == [0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C]
            }
        }
    }
}

extension VideoFileType: ByteMatchable {

    public var bytesCount: Int {
        switch self {
        case .mp4: return 28
        case .m4v, .avi: return 11
        case .mkv, .webm, .mpg, .flv: return 4
        case .mov: return 8
        case .wmv: return 10
        }
    }

    public var matches: ([UInt8], Data) -> Bool {
        switch self {
        case .mp4: return { bytes, _ in
                if bytes[0...2] == [0x00, 0x00, 0x00] && (bytes[3] == 0x18 || bytes[3] == 0x20) && bytes[4...7] == [0x66, 0x74, 0x79, 0x70] {
                    return true
                } else if bytes[0...3] == [0x33, 0x67, 0x70, 0x35] {
                    return true
                } else if bytes[0...11] == [0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32] && bytes[16...27] == [0x6D, 0x70, 0x34, 0x31, 0x6D, 0x70, 0x34, 0x32, 0x69, 0x73, 0x6F, 0x6D] {
                    return true
                } else if bytes[0...11] == [0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32, 0x00, 0x00, 0x00, 0x00] {
                    return true
                }
                return false
            }
        case .m4v: return { bytes, _ in
                bytes[0...10] == [0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x56]
            }
        case .mkv: return { bytes, data in
            guard bytes[0...3] == [0x1A, 0x45, 0xDF, 0xA3] else { return false }

            let _bytes = Array(data.readBytes(count: 4100)[4 ..< 4100])
            var idPos = -1

            for i in 0 ..< (_bytes.count - 1) {
                if _bytes[i] == 0x42 && _bytes[i + 1] == 0x82 {
                    idPos = i
                    break
                }
            }

            guard idPos > -1 else { return false }

            let docTypePos = idPos + 3
            let findDocType: (String) -> Bool = { type in
                for i in 0 ..< type.count {
                    let index = type.index(type.startIndex, offsetBy: i)
                    let scalars = String(type[index]).unicodeScalars

                    if _bytes[docTypePos + i] != UInt8(scalars[scalars.startIndex].value) {
                        return false
                    }
                }
                return true
            }
            return findDocType("matroska")
        }
        case .webm: return { bytes, data in
            guard bytes[0...3] == [0x1A, 0x45, 0xDF, 0xA3] else {
                return false
            }

            let _bytes = Array(data.readBytes(count: 4100)[4 ..< 4100])
            var idPos = -1

            for i in 0 ..< (_bytes.count - 1) {
                if _bytes[i] == 0x42 && _bytes[i + 1] == 0x82 {
                    idPos = i
                    break
                }
            }

            guard idPos > -1 else { return false }

            let docTypePos = idPos + 3
            let findDocType: (String) -> Bool = { type in
            for i in 0 ..< type.count {
                let index = type.index(type.startIndex, offsetBy: i)
                let scalars = String(type[index]).unicodeScalars
                    if _bytes[docTypePos + i] != UInt8(scalars[scalars.startIndex].value) {
                        return false
                    }
                }
                return true
            }
            return findDocType("webm")
        }
        case .mov: return { bytes, _ in
            bytes[0...7] == [0x00, 0x00, 0x00, 0x14, 0x66, 0x74, 0x79, 0x70]
        }
        case .avi: return { bytes, _ in
            (bytes[0...3] == [0x52, 0x49, 0x46, 0x46]) && (bytes[8...10] == [0x41, 0x56, 0x49])
        }
        case .mpg: return { bytes, _ in
            guard bytes[0...2] == [0x00, 0x00, 0x01] else { return false }
            let hexCode = String(format: "%2X", bytes[3])
            return hexCode.first != nil && hexCode.first! == "B"
        }
        case .flv: return { bytes, _ in
            bytes[0...3] == [0x46, 0x4C, 0x56, 0x01]
        }
        case .wmv: return { bytes, _ in
                bytes[0...9] == [0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11, 0xA6, 0xD9]
            }
        }
    }
}

extension AudioFileType: ByteMatchable {

    public var bytesCount: Int {
        switch self {
        case .mid, .ogg, .flac: return 4
        case .mp3: return 3
        case .m4a: return 11
        case .opus: return 36
        case .wav: return 12
        case .amr: return 6
        }
    }

    public var matches: ([UInt8], Data) -> Bool {
        switch self {
        case .mid: return { bytes, _ in
                bytes[0...3] == [0x4D, 0x54, 0x68, 0x64]
            }
        case .mp3: return { bytes, _ in
                (bytes[0...2] == [0x49, 0x44, 0x33]) || (bytes[0...1] == [0xFF, 0xFB])
            }
        case .m4a: return { bytes, _ in
                (bytes[0...3] == [0x4D, 0x34, 0x41, 0x20]) || (bytes[4...10] == [0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x41])
            }
        case .opus: return { bytes, _ in
                bytes[28...35] == [0x4F, 0x70, 0x75, 0x73, 0x48, 0x65, 0x61, 0x64]
            }
        case .ogg: return { bytes, _ in
                bytes[0...3] == [0x4F, 0x67, 0x67, 0x53]
            }
        case .flac: return { bytes, _ in
                bytes[0...3] == [0x66, 0x4C, 0x61, 0x43]
            }
        case .wav: return { bytes, _ in
                (bytes[0...3] == [0x52, 0x49, 0x46, 0x46]) && (bytes[8...11] == [0x57, 0x41, 0x56, 0x45])
            }
        case .amr: return { bytes, _ in
                bytes[0...5] == [0x23, 0x21, 0x41, 0x4D, 0x52, 0x0A]
            }
        }
    }
}

// MARK: - Data

extension Data {
    internal func readBytes(count: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count)
        return bytes
    }
}

public extension Data {

    func mimeFileType() -> MimeType? {
        let bytes = readBytes(count: Swift.min(self.count, 262))

        let arr: [[ByteMatchable & AnyKnownFileType & MimeTypeRepresentable]] = [
            ImageFileType.allCases,
            BinaryFileType.allCases,
            ArchiveFileType.allCases,
            VideoFileType.allCases,
            AudioFileType.allCases
        ]

        for list in arr {
            let some = list.first(where: {
                $0.bytesCount <= bytes.count && $0.matches(bytes, self)
            })
            guard let result = some else { continue }
            let ext = result.mimeType.components(separatedBy: "/")
            return MimeType(mime: result.mimeType, extension: ext.last ?? result.mimeType, fileType: result)
        }

        return nil
    }
}

// MARK: - MimeType Result

public struct MimeType {
    public let mime: String
    public let `extension`: String
    public let fileType: AnyKnownFileType
}

