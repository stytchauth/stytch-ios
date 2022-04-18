import Foundation

extension String {
    var base64Encoded: String {
        Data(utf8).base64EncodedString()
    }

    func dropLast(while predicate: (Character) throws -> Bool) rethrows -> Substring {
        try Substring(reversed().drop(while: predicate).reversed())
    }
}
