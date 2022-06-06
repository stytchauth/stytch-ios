import Foundation

extension CSV: RandomAccessCollection {
    func index(after i: Int) -> Int {
        rows.index(after: i)
    }

    var startIndex: Int {
        rows.startIndex
    }

    var endIndex: Int {
        rows.endIndex
    }

    mutating func append(_ row: Row) {
        rows.append(row)
    }

    subscript (index: Int) -> Row {
        get { rows[index] }
        set { rows[index] = newValue }
    }
}

struct CSV<Row: CSVRow> {
    private var rows: [Row]

    init(url: URL) throws {
        self = try .parse(String(contentsOf: url))
    }

    init(rows: [Row] = []) {
        self.rows = rows
    }

    func save(to url: URL) throws {
        try Data(
            stringValue().utf8
        ).write(to: url)
    }

    private func stringValue() throws -> String {
        let encodeColumn: (String) -> EncodedColumn = { .init(rawValue: $0.contains(" ") ? "\"\($0)\"" : $0) }
        let encodeRow: ([EncodedColumn]) -> String = { $0.map(\.rawValue).joined(separator: ",") }
        var encodedRows: [String] = [encodeRow(Row.headerNames.map(encodeColumn))]
        encodedRows.append(
            contentsOf: try rows.map { row in
                let row = Row.encodedRow(row, encodeColumn: encodeColumn)
                if row.count != Row.headerNames.count {
                    throw CSVError()
                }
                return encodeRow(row)
            }
        )
        return encodedRows.joined(separator: "\n")
    }

    static func parse(_ string: String) throws -> CSV {
        self.init(
            rows: try string.components(separatedBy: "\n")
                .dropFirst()
                .lazy
                .filter { !$0.isEmpty }
                .map(parseRow(_:))
        )
    }

    private static func parseRow(_ string: String) throws -> Row {
        let scanner = Scanner(string: string)
        let commaSet = CharacterSet(charactersIn: ",")
        let quoteSet = CharacterSet(charactersIn: "\"")

        var result: [String] = []

        while !scanner.isAtEnd {
            if scanner.next == "\"" {
                scanner.charactersToBeSkipped = quoteSet
                scanner.scanUpToCharacters(from: quoteSet).map { result.append($0) }
                _ = scanner.scanCharacter()
            } else {
                scanner.charactersToBeSkipped = commaSet
                scanner.scanUpToCharacters(from: commaSet).map { result.append($0) }
            }
        }

        return try Row.from(&result)
    }
}

struct EncodedColumn {
    fileprivate let rawValue: String

    fileprivate init(rawValue: String) {
        self.rawValue = rawValue
    }
}

protocol CSVRow {
    static func from(_ strings: inout [String]) throws -> Self
    static func encodedRow(_ value: Self, encodeColumn: (String) -> EncodedColumn) -> [EncodedColumn]
    static var headerNames: [String] { get }
}

private extension Scanner {
    var next: Character? { string[currentIndex] }
}

struct CSVError: Error {}
