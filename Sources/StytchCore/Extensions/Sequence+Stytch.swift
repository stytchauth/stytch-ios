extension Sequence where Element: CVarArg {
    func toHexString() -> String {
        reduce(into: "") { $0 += String(format: "%02x", $1) }
    }
}
