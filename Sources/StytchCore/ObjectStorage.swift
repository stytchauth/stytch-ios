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
    var item: EncryptedUserDefaultsItem { get }
    func setObject(object: ObjectType?)
    func getObject() throws -> ObjectType?
}

extension ObjectStorageWrapper {
    var userDefaultsClient: EncryptedUserDefaultsClient {
        Current.userDefaultsClient
    }

    var queryResult: EncryptedUserDefaultsItemResult? {
        try? userDefaultsClient.getItem(item: item)
    }

    var lastValidatedAtDate: Date? {
        let last = try? userDefaultsClient.getObject(Date.self, for: EncryptedUserDefaultsItem.lastValidatedAtDate(item.name))
        return last
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
    let item = EncryptedUserDefaultsItem.session

    func setObject(object: Session?) {
        try? userDefaultsClient.setObjectValue(object, for: item)
    }

    func getObject() throws -> Session? {
        var sessionToReturn: Session? = try userDefaultsClient.getObject(Session.self, for: item)
        if let session = sessionToReturn, session.expiresAt.isInThePast {
            sessionToReturn = nil
            sessionManager.resetSession()
        }
        return sessionToReturn
    }
}

class MemberSessionStorageWrapper: ObjectStorageWrapper {
    @Dependency(\.sessionManager) var sessionManager
    let item = EncryptedUserDefaultsItem.memberSession

    func setObject(object: MemberSession?) {
        try? userDefaultsClient.setObjectValue(object, for: item)
    }

    func getObject() throws -> MemberSession? {
        var sessionToReturn: MemberSession? = try userDefaultsClient.getObject(MemberSession.self, for: item)
        if let session = sessionToReturn, session.expiresAt.isInThePast {
            sessionToReturn = nil
            sessionManager.resetSession()
        }
        return sessionToReturn
    }
}

class UserStorageWrapper: ObjectStorageWrapper {
    let item = EncryptedUserDefaultsItem.user

    func setObject(object: User?) {
        try? userDefaultsClient.setObjectValue(object, for: item)
    }

    func getObject() throws -> User? {
        try userDefaultsClient.getObject(User.self, for: item)
    }
}

class MemberStorageWrapper: ObjectStorageWrapper {
    let item = EncryptedUserDefaultsItem.member

    func setObject(object: Member?) {
        try? userDefaultsClient.setObjectValue(object, for: item)
    }

    func getObject() throws -> Member? {
        try userDefaultsClient.getObject(Member.self, for: item)
    }
}

class OrganizationStorageWrapper: ObjectStorageWrapper {
    let item = EncryptedUserDefaultsItem.organization

    func setObject(object: Organization?) {
        try? userDefaultsClient.setObjectValue(object, for: item)
    }

    func getObject() throws -> Organization? {
        try userDefaultsClient.getObject(Organization.self, for: item)
    }
}

extension Date {
    var isInThePast: Bool {
        self < Date()
    }
}
