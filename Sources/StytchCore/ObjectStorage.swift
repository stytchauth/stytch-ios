import Combine
import Foundation

// swiftlint:disable type_contents_order

protocol ObjectStorageWrapper {
    associatedtype ObjectType
    func setObject(object: ObjectType?)
    func getObject() -> ObjectType?
}

class ObjectStorage<WrapperType: ObjectStorageWrapper> {
    let objectWrapper: WrapperType

    init(objectWrapper: WrapperType) {
        self.objectWrapper = objectWrapper
    }

    private(set) var object: WrapperType.ObjectType? {
        get { objectWrapper.getObject() }
        set { objectWrapper.setObject(object: newValue) }
    }

    private(set) lazy var onChange = _onChange
        .map { [weak self] in self?.object == nil }
        .removeDuplicates()
        .map { [weak self] _ in self?.object }

    private let _onChange = PassthroughSubject<Void, Never>()

    func update(_ object: WrapperType.ObjectType) {
        self.object = object
        _onChange.send(())
    }

    func reset() {
        object = nil
        _onChange.send(())
    }
}

class UserStorageWrapper: ObjectStorageWrapper {
    @Dependency(\.localStorage) var localStorage

    func setObject(object: User?) {
        localStorage.user = object
    }

    func getObject() -> User? {
        localStorage.user
    }
}

class MemberStorageWrapper: ObjectStorageWrapper {
    @Dependency(\.localStorage) var localStorage

    func setObject(object: Member?) {
        localStorage.member = object
    }

    func getObject() -> Member? {
        localStorage.member
    }
}

class OrganizationStorageWrapper: ObjectStorageWrapper {
    @Dependency(\.localStorage) var localStorage

    func setObject(object: Organization?) {
        localStorage.organization = object
    }

    func getObject() -> Organization? {
        localStorage.organization
    }
}
