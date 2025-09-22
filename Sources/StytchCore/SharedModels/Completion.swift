/// A generic asynchronous callback returning a `Result<T, Error>`.
public typealias Completion<T> = (Result<T, Error>) -> Void
