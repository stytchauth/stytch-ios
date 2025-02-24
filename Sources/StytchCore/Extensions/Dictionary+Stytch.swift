import CoreFoundation
import Foundation

extension Dictionary where Key == CFString, Value == Any {
    func merging(_ other: Self) -> CFDictionary {
        merging(other) { $1 } as CFDictionary
    }
}

extension Dictionary where Key == String, Value == String {
    func appendingPrefix(_ prefix: String) -> [String: String] {
        reduce(into: [String: String]()) { result, pair in
            result["\(prefix)_\(pair.key)"] = pair.value
        }
    }
}
