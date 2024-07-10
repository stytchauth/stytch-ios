import Foundation

struct IntermediateSessionTokenParameters<T: Encodable>: Encodable {
    private enum CodingKeys: String, CodingKey {
        case intermediateSessionToken
    }

    let intermediateSessionToken: String
    let wrapped: T

    init(intermediateSessionToken: String, wrapped: T) {
        self.intermediateSessionToken = intermediateSessionToken
        self.wrapped = wrapped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try wrapped.encode(to: encoder)
        try container.encode(intermediateSessionToken, forKey: .intermediateSessionToken)
    }
}
