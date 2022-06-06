import Foundation

final class StorageClient<T: Identifiable & Codable> where T.ID: Codable {
    private var storage: Storage

    private let url: URL

    func upsert(_ value: T) {
        storage.values[value.id] = value
    }

    func value(id: T.ID) -> T? {
        storage.values[id]
    }

    init(path: String) {
        self.url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("stytch-demo/storage")
            .appendingPathComponent(path)
            .appendingPathExtension("json")
        do {
            storage = try FileManager.default.contents(atPath: url.path).map { data in
                try JSONDecoder().decode(Storage.self, from: data)
            } ?? .init(values: [:])
        } catch {
            storage = .init(values: [:])
        }
    }


    func save() throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(
                at: url.pathExtension.isEmpty ? url : url.deletingPathExtension().deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        }
        try JSONEncoder().encode(storage).write(to: url)
    }

    struct Storage: Codable {
        var values: [T.ID: T] = [:]
    }
}
