enum OTPRoute: RouteType {
    case authenticate
    case loginOrCreate(DeliveryMethod)
    case sendPrimary(DeliveryMethod)
    case sendSecondary(DeliveryMethod)

    var path: Path {
        switch self {
        case .authenticate:
            return "authenticate"
        case let .loginOrCreate(deliveryMethod):
            return deliveryMethod.path.appendingPath("login_or_create")
        case let .sendPrimary(deliveryMethod):
            return deliveryMethod.path.appendingPath("send/primary")
        case let .sendSecondary(deliveryMethod):
            return deliveryMethod.path.appendingPath("send/secondary")
        }
    }
}

extension OTPRoute {
    typealias DeliveryMethod = StytchClient.OTP.DeliveryMethod
}
