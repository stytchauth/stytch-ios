//
//  InMemoryStorage.swift
//  StytchDemo (Server)
//
//  Created by Dan Loman on 6/5/22.
//

import Foundation

let serverStorage: ServerStorage = .init()

final class ServerStorage {
    struct Key<T>: Hashable {
        let uuid: UUID = .init()

        let convert: (T) throws -> Data
        let unconvert: (Data) throws -> T

        init(convert: @escaping (T) throws -> Data, unconvert: @escaping (Data) throws -> T) {
            self.convert = convert
            self.unconvert = unconvert
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.uuid == rhs.uuid
        }
    }

    private var rawStorage: [UUID: Data] = [:]

    func valueForKey<T>(_ key: Key<T>) -> T? {
        try? rawStorage[key.uuid].map(key.unconvert)
    }

    func setValue<T>(_ value: T, forKey key: Key<T>) {
        rawStorage[key.uuid] = try? key.convert(value)
    }
}
