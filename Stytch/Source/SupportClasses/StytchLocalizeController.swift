//
//  StytchLocalizeController.swift
//  Stytch
//
//  Created by Edgar Kroman on 2020-12-07.
//

import Foundation

class StytchLocalizeController: NSObject {
    
    static let shared = StytchLocalizeController()
    private override init() {
        super.init()
        loadStrings()
    }
    
    var enStrings = [String: String]()
    
    func loadStrings() {
        enStrings.removeAll()
        
        let bundle = Bundle(for: StytchAuthViewController.self)
        
        if let path = bundle.path(forResource: "en", ofType: "strings"),
            let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] {
            enStrings = dictionary
        }
        
    }
    
    func stringFor(_ key: String) -> String {
        return enStrings[key] ?? ""
    }

}

extension String {
    
    var localized: String {
        return StytchLocalizeController.shared.stringFor(self)
    }
    
}

