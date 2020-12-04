//
//  URL+Query.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-20.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value?.removingPercentEncoding?.removingPercentEncoding
    }
}
