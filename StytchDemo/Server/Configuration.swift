import Foundation

let configuration: Configuration = {
    do {
        let data = try JSONEncoder().encode(ProcessInfo.processInfo.environment)
        return try JSONDecoder().decode(Configuration.self, from: data)
    } catch {
        fatalError("ERROR generating config from Environment")
    }
}()

struct Configuration: Decodable {
    let appId: String

    private enum CodingKeys: String, CodingKey { case appId = "APP_ID" }
}
