import Swifter

protocol Controller {
    init(request: HttpRequest)
}

extension HttpServer.MethodRoute {
    subscript<T: Controller>(path: String) -> ((T) -> () async -> HttpResponse)? {
        get { nil }
        set {
            guard let newValue = newValue else { return }
            router.register(method, path: path) { request in
                await newValue(T(request: request))()
            }
        }
    }
}
