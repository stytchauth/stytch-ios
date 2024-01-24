enum EventsRoute: RouteType {
    case logEvents

    var path: Path {
        switch self {
        case .logEvents:
            return "events"
        }
    }
}
