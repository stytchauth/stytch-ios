//
//  MultipartObject.swift
//
//  Copyright © 2020 Logicants. All rights reserved.
//

import Foundation

struct MultipartObject {
    
    var key: String
    var value: Any
    var mimeType: String
    
    func generatedBody(_ boundary: String, namePostfix: String = "") -> Data {
        
        if let string = value as? String {
            return bodyFrom(value: string, key: key, boundary: boundary)
            
        } else if let data = value as? Data {
            let namePrefix = mimeType.split(separator: "/").last ?? "file"
            var name = "\(namePrefix)"
            if !namePostfix.isEmpty {
                name += "_\(namePostfix).\(namePrefix)"
            }
            
            return bodyFrom(filePathKey: key, filename: name, mimeType: mimeType, fileBuffer: data, boundary: boundary)
        }
        
        return Data()
    }
    
    private func bodyFrom(filePathKey: String, filename: String, mimeType: String, fileBuffer: Data, boundary: String) -> Data {
        
        var body = Data()
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileBuffer)
        body.appendString("\r\n")
        
        return body
    }
    
    private func bodyFrom(value: String, key: String, boundary: String) -> Data {
        
        var body = Data()
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        body.appendString("\(value)\r\n")
        
        return body
    }
}

extension Data {
    
    mutating func appendString(_ value: String) {
        if let data = value.data(using: String.Encoding.utf8) {
             self.append(data)
        }
    }
}
