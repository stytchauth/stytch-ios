extension Sequence {
    func firstAs<T>(_ transform: (Element) -> T?) -> T? {
        for element in self {
            if let result = transform(element) {
                return result
            }
        }
        return nil
    }
}
