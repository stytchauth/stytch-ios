// protocol SessionResponseType {
//    var sessionToken: String { get }
//    var sessionJwt: String { get }
//    var session: Session { get }
// }
//
// extension Response: SessionResponseType where Wrapped: SessionResponseType {
//    var sessionToken: String {
//        self[dynamicMember: \.sessionToken]
//    }
//
//    var sessionJwt: String {
//        self[dynamicMember: \.sessionJwt]
//    }
//
//    var session: Session {
//        self[dynamicMember: \.session]
//    }
// }
