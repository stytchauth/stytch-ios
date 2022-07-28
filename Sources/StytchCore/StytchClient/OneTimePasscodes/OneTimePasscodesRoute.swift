enum OneTimePasscodesRoute: RouteType {
    case authenticate
    case loginOrCreate(StytchClient.OneTimePasscodes.LoginOrCreateParameters.DeliveryMethod)

    var path: Path {
        switch self {
        case .authenticate:
            return "authenticate"
        case let .loginOrCreate(deliveryMethod):
            return deliveryMethod.path.appendingPath("login_or_create")
        }
    }
}
