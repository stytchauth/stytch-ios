import XCTest
@testable import StytchCore

final class BootstrapTestCase: BaseTestCase {
    
    var bootstrapResponseData: BootstrapResponseData!
    
    override func setUpWithError() throws {
        let data = loadData("bootstrap", extensionType: "json")
        bootstrapResponseData = BootstrapResponseData.mock(data)
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        bootstrapResponseData = nil
        try super.tearDownWithError()
    }
    
    func testRBAC() {
        
    }
}

extension BootstrapResponseData {
    static func mock(_ data: Data?) -> BootstrapResponseData? {
        guard let data else {
            return nil
        }
        let decoder = JSONDecoder()
        let bootstrapResponseData = try? decoder.decode(BootstrapResponseData.self, from: data)
        return bootstrapResponseData
    }
}
