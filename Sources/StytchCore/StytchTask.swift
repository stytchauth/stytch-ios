public struct StytchTask<Parameters, Response> {
    let task: (Parameters, @escaping Completion<Response>) -> Void

    init(task: @escaping (Parameters, @escaping Completion<Response>) -> Void) {
        self.task = task
    }

    public func start(using parameters: Parameters, completion: @escaping Completion<Response>) {
        task(parameters, completion)
    }
}

#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
extension StytchTask {
    @available(iOS 13.0, *) // FIXME: - add compiler directive
    public func start(using parameters: Parameters) -> AnyPublisher<Response, Error> {
        Deferred {
            Future({ promise in
                self.start(using: parameters, completion: promise)
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif

#if compiler(>=5.5) && canImport(_Concurrency)
extension StytchTask {
    #if compiler(>=5.5.2)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    public func start(using parameters: Parameters) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.start(using: parameters, completion: continuation.resume)
        }
    }
    #else
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public func start(using parameters: Parameters) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.start(using: parameters, completion: continuation.resume)
        }
    }
    #endif
}
#endif
