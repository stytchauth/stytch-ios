import Foundation

struct IntermediateSessionTokenParameters<T: Encodable>: Encodable {
    private enum CodingKeys: String, CodingKey {
        case intermediateSessionToken
    }

    let intermediateSessionToken: String?
    let wrapped: T

    // swiftlint:disable:next unneeded_synthesized_initializer
    init(intermediateSessionToken: String?, wrapped: T) {
        self.intermediateSessionToken = intermediateSessionToken
        self.wrapped = wrapped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try wrapped.encode(to: encoder)
        if let intermediateSessionToken {
            try container.encode(intermediateSessionToken, forKey: .intermediateSessionToken)
        }
    }
}

struct IntermediateSessionTokenParametersWithNoWrappedValue: Codable {
    let intermediateSessionToken: String?

    // swiftlint:disable:next unneeded_synthesized_initializer
    init(intermediateSessionToken: String?) {
        self.intermediateSessionToken = intermediateSessionToken
    }
}
