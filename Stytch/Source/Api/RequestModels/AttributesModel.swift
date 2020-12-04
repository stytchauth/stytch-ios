//
//  AttributesModel.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-18.
//

import Foundation
import WebKit

class AttributesModel: Codable {
    var ip_address: String?
    var user_agent: String?
    
    static var preloadedAgent: String?
    
    init() {
        ip_address = getAddress()
        user_agent = AttributesModel.preloadedAgent
    }
    
    private func getAddress() -> String? {
        var address: String?

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
        freeifaddrs(ifaddr)

        return address
    }

}
