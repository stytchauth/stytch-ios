import Foundation

@propertyWrapper
struct LossyArray<T: Decodable>: Decodable {
    private struct AnyDecodableValue: Decodable {}

    var wrappedValue: [T]

    init(wrappedValue: [T]) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var elements: [T] = []

        while !container.isAtEnd {
            do {
                elements.append(try container.decode(T.self))
            } catch {
                _ = try? container.decode(AnyDecodableValue.self)
            }
        }

        wrappedValue = elements
    }
}
