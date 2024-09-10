import StytchCore

extension User.Name {
    init?(_ name: String) {
        let components = name
            .split(separator: " ")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        switch components.count {
        case 1:
            self = User.Name(firstName: components[0])
        case 2:
            self = User.Name(firstName: components[0], lastName: components[1])
        case 3:
            self = User.Name(firstName: components[0], lastName: components[2], middleName: components[1])
        default:
            return nil
        }
    }

    var fullName: String {
        var name = ""
        if let firstName {
            name = firstName
        }
        if let middleName, middleName != "" {
            name = "\(name) \(middleName)"
        }
        if let lastName, lastName != "" {
            name = "\(name) \(lastName)"
        }
        return name
    }
}
