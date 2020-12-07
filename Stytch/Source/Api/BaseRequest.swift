//
//  BaseRequest.swift
//
//  Copyright © 2020 Logicants. All rights reserved.
//

import Foundation

class BaseRequest<RequestModel: Codable, ResponseModel: Codable>: BaseApi {
    
    private var url: URL
    private var method: RequestMethod
    private var httpBodyObject: RequestModel?
    private var headers: [String:String]
    var urlRequest: URLRequest
    
    init(_ url: URL, method: RequestMethod, object: RequestModel?, headers: [String: String], contentType: ContentType = .APP_JSON, multipart: [MultipartObject] = []) {
        self.url = url
        self.method = method
        self.httpBodyObject = object
        self.headers = headers
        
        urlRequest = URLRequest(url: url)
        
        for header in headers {
            StytchLog.show("Header:", header.key, header.value)
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        let encoder = JSONEncoder()
        
        if contentType == .MULTIPART {
            var body = Data()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let fileDate = "\(formatter.string(from: Date()))"
            let boundary = BaseRequest.generateBoundaryString()
            
            urlRequest.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
            StytchLog.show("Header:", "Content-Type", "multipart/form-data; boundary=" + boundary)
            
            for part in multipart {
                
                body.append(part.generatedBody(boundary, namePostfix: fileDate))
            }

            body = BaseRequest.closeBody(body, boundary: boundary)
            urlRequest.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
            StytchLog.show("Header:", "Content-Length", String(body.count))
            urlRequest.httpShouldHandleCookies = false
            
            urlRequest.httpBody = body
        } else {
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            StytchLog.show("Header:", "Content-Type", "application/json")
            
            if let obj = object {
                do {
                    let data = try encoder.encode(obj)
                    urlRequest.httpBody = data
                } catch let ecodeError {
                    StytchLog.show("Parse error:", ecodeError)
                }
            }
        }
        
        urlRequest.httpMethod = method.rawValue
        StytchLog.show("URLRequest:", method.rawValue, urlRequest.url?.absoluteString ?? "")
        
        if (urlRequest.httpBody?.count ?? 10001) < 10000 {
            StytchLog.show("HttpBody:", String(data: urlRequest.httpBody ?? Data(), encoding: String.Encoding.utf8) ?? "none string")
        }
        super.init()
    }
    
    func resetHeader(_ header: (String, String)) {
        urlRequest.setValue(header.0, forHTTPHeaderField: header.1)
    }
    
    func send(handler: @escaping(BaseResponseModel<ResponseModel>)->()) {
        createDataTask(urlRequest, handler: handler)
    }
    
    func sendSync() -> Data? {
        return createSyncDataTask(urlRequest)
    }
    
    static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    static func closeBody(_ data: Data, boundary: String) -> Data {
        var body = data
        
        if let data = "--\(boundary)--\r\n".data(using: String.Encoding.utf8) {
            body.append(data)
        }

        return body
    }

}

