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
            #if DEBUG
            print("Header:", header.key, header.value)
            #endif
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
            #if DEBUG
            print("Header:", "Content-Type", "multipart/form-data; boundary=" + boundary)
            #endif
            
            for part in multipart {
                
                body.append(part.generatedBody(boundary, namePostfix: fileDate))
            }

            body = BaseRequest.closeBody(body, boundary: boundary)
            urlRequest.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
            #if DEBUG
            print("Header:", "Content-Length", String(body.count))
            #endif
            urlRequest.httpShouldHandleCookies = false
            
            urlRequest.httpBody = body
        } else {
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            #if DEBUG
            print("Header:", "Content-Type", "application/json")
            #endif
            
            if let obj = object {
                do {
                    let data = try encoder.encode(obj)
                    urlRequest.httpBody = data
                } catch let ecodeError {
                    #if DEBUG
                    print("Parse error:", ecodeError)
                    #endif
                }
            }
        }
        
        urlRequest.httpMethod = method.rawValue
        #if DEBUG
        print("URLRequest:", method.rawValue, urlRequest.url?.absoluteString ?? "")
        #endif
        
        #if DEBUG
        if (urlRequest.httpBody?.count ?? 10001) < 10000 {
            print("HttpBody:", String(data: urlRequest.httpBody ?? Data(), encoding: String.Encoding.utf8) ?? "none string")
        }
        #endif
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

