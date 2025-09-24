#if !os(tvOS) && !os(watchOS)
import LocalAuthentication

/// A protocol abstraction over `LAContext` to enable unit testing of biometric logic.
///
/// Direct usage of `LAContext` in tests is impractical because `canEvaluatePolicy`
/// and `evaluatePolicy` depend on actual device hardware and biometric configuration.
/// By conforming `LAContext` to this protocol and providing a mock implementation,
/// we can inject a controllable context into our biometric flow for reliable testing.
public protocol LAContextEvaluating {
    var biometryType: LABiometryType { get }

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool
}

extension LAContext: LAContextEvaluating {}
#endif
