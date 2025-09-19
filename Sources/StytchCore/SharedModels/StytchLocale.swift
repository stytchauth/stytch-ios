import Foundation

// swiftlint:disable identifier_name

/// Used to determine which language to use when sending the user this delivery method. Parameter is a IETF BCP 47 language tag, e.g. "en".
/// https://www.w3.org/International/articles/language-tags/
public enum StytchLocale: String, Codable, Sendable {
    case en
    case es
    case ptbr = "pt-br"
}
