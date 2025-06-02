import Combine
import Foundation

// swiftlint:disable type_contents_order let_var_whitespace

/// StytchObjectInfo provides a generic way to unify the publishing of Stytch object types.
/// If there is an object to publish you will get `case available(T, Date)`, which will publish the object
/// and the date is was last validated at. The receiver of the event if the object is within their time tolerance for use.
/// If there is no object to publish you will get `case unavailable(KeychainError?)`. So the publisher will never have to publish a nil value.
public enum StytchObjectInfo<T: Equatable>: Equatable {
    case unavailable(KeychainError?)
    case available(T, Date)
}

/*
 The ObjectStorage and ObjectStorageWrapper classes are designed to provide generic interfaces for observing changes in object states via the onChange subject.
 Each specific implementation of ObjectStorageWrapper can determine its own caching strategy.
 Whenever the caller invokes the update method, the underlying ObjectStorageWrapper modifies the object, and ObjectStorage publishes the updated value.
 */

protocol ObjectStorageWrapper {
    associatedtype ObjectType: Equatable
    var lastValidatedAtDate: Date? { get }
    var keychainItem: KeychainItem { get }
    func setObject(object: ObjectType?)
    func getObject() throws -> ObjectType?
}

extension ObjectStorageWrapper {
    var keychainClient: KeychainClient {
        Current.keychainClient
    }

    var queryResult: KeychainQueryResult? {
        try? keychainClient.getFirstQueryResult(keychainItem)
    }

    var lastValidatedAtDate: Date? {
        queryResult?.modifiedAt
    }
}

class ObjectStorage<WrapperType: ObjectStorageWrapper> {
    private let objectWrapper: WrapperType
    private var cancellable: AnyCancellable?

    private let _onChange = PassthroughSubject<StytchObjectInfo<WrapperType.ObjectType>, Never>()
    var onChange: AnyPublisher<StytchObjectInfo<WrapperType.ObjectType>, Never> {
        _onChange.removeDuplicates().eraseToAnyPublisher()
    }

    init(objectWrapper: WrapperType) {
        self.objectWrapper = objectWrapper

        // only observe the first fire of this event so that we can publish objects on startup
        cancellable = StartupClient.isInitialized.first().sink { [weak self] _ in
            self?.publish()
        }
    }

    var object: WrapperType.ObjectType? {
        try? objectWrapper.getObject()
    }

    func update(_ object: WrapperType.ObjectType?) {
        objectWrapper.setObject(object: object)
        publish()
    }

    private func publish() {
        do {
            if let object = try objectWrapper.getObject(), let lastValidatedAtDate = objectWrapper.lastValidatedAtDate {
                _onChange.send(.available(object, lastValidatedAtDate))
            } else {
                _onChange.send(.unavailable(nil))
            }
        } catch let error as KeychainError {
            _onChange.send(.unavailable(error))
        } catch {
            _onChange.send(.unavailable(nil))
        }
    }
}

class SessionStorageWrapper: ObjectStorageWrapper {
    @Dependency(\.sessionManager) var sessionManager
    let keychainItem = KeychainItem.session

    func setObject(object: Session?) {
        try? keychainClient.setObject(object, for: keychainItem)
    }

    func getObject() throws -> Session? {
        do {
            var sessionToReturn: Session? = try keychainClient.getObject(Session.self, for: keychainItem)
            if let session = sessionToReturn, session.expiresAt.isInThePast {
                sessionToReturn = nil
                sessionManager.resetSession()
            }
            return sessionToReturn
        } catch {
            sessionManager.resetSession()
            throw error
        }
    }
}

class MemberSessionStorageWrapper: ObjectStorageWrapper {
    @Dependency(\.sessionManager) var sessionManager
    let keychainItem = KeychainItem.memberSession

    func setObject(object: MemberSession?) {
        try? keychainClient.setObject(object, for: keychainItem)
    }

    func getObject() throws -> MemberSession? {
        do {
            var sessionToReturn: MemberSession? = try keychainClient.getObject(MemberSession.self, for: keychainItem)
            if let session = sessionToReturn, session.expiresAt.isInThePast {
                sessionToReturn = nil
                sessionManager.resetSession()
            }
            return sessionToReturn
        } catch {
            sessionManager.resetSession()
            throw error
        }
    }
}

class UserStorageWrapper: ObjectStorageWrapper {
    let keychainItem = KeychainItem.user

    func setObject(object: User?) {
        try? keychainClient.setObject(object, for: keychainItem)
    }

    func getObject() throws -> User? {
        try keychainClient.getObject(User.self, for: keychainItem)
    }
}

class MemberStorageWrapper: ObjectStorageWrapper {
    let keychainItem = KeychainItem.member

    func setObject(object: Member?) {
        try? keychainClient.setObject(object, for: keychainItem)
    }

    func getObject() throws -> Member? {
        try keychainClient.getObject(Member.self, for: keychainItem)
    }
}

class OrganizationStorageWrapper: ObjectStorageWrapper {
    let keychainItem = KeychainItem.organization

    func setObject(object: Organization?) {
        try? keychainClient.setObject(object, for: keychainItem)
    }

    func getObject() throws -> Organization? {
        try keychainClient.getObject(Organization.self, for: keychainItem)
    }
}

extension Date {
    var isInThePast: Bool {
        self < Date()
    }
}
