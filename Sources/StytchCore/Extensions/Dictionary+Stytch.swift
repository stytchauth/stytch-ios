import Foundation

extension Dictionary where Key == CFString, Value == Any {
    func merging(_ other: Self) -> CFDictionary {
        merging(other) { $1 } as CFDictionary
    }
}
