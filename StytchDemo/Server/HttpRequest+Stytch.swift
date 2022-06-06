import Swifter

extension HttpRequest {
    var cookies: [(name: String, value: String)] {
        (headers["cookie"] ?? headers["Cookie"])?
            .components(separatedBy: "; ")
            .map { $0.components(separatedBy: "=") }
            .map { ($0[0], $0[1]) } ?? []
    }
}
