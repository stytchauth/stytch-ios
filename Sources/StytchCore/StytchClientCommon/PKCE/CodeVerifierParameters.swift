import Foundation

struct CodeVerifierParameters<T: Encodable>: Encodable {
    let codingPrefix: CodeCodingPrefix?
    let codeVerifier: String
    let wrapped: T

    init(codingPrefix: CodeCodingPrefix? = nil, codeVerifier: String, wrapped: T) {
        self.codingPrefix = codingPrefix
        self.codeVerifier = codeVerifier
        self.wrapped = wrapped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try wrapped.encode(to: encoder)

        try container.encode(codeVerifier, forKey: .codeVerifier(prefix: codingPrefix?.rawValue))
    }
}

extension CodeVerifierParameters {
    private struct CodingKeys: CodingKey {
        let prefix: String?
        let rawValue: String
        let intValue: Int? = nil

        var stringValue: String {
            [prefix, rawValue].compactMap { $0 }.joined(separator: "_")
        }

        private init(prefix: String?, rawValue: String) {
            self.prefix = prefix
            self.rawValue = rawValue
        }

        init?(stringValue _: String) {
            nil
        }

        init?(intValue _: Int) {
            nil
        }

        static func codeVerifier(prefix: String?) -> Self {
            .init(prefix: prefix, rawValue: "code_verifier")
        }
    }
}
