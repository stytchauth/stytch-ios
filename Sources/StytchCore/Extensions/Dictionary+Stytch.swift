import CoreFoundation
import Foundation

extension Dictionary where Key == CFString, Value == Any {
    func merging(_ other: Self) -> CFDictionary {
        merging(other) { $1 } as CFDictionary
    }

    func accessibilityAwareMerging(_ other: Self) -> CFDictionary {
        var combined = merging(other) { $1 } as [CFString: Any]
        if combined[kSecAttrAccessible] != nil, combined[kSecAttrAccessControl] != nil {
            // we can't have both, so prefer kSecAttrAccessControl
            combined.removeValue(forKey: kSecAttrAccessible)
        }
        return combined as CFDictionary
    }
}
