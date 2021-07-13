//
//  BaseApi.swift
//
//  Copyright © 2020 Logicants. All rights reserved.
//

import UIKit

extension URLSession {
    func synchronousDataTask(with request: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: request) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}

enum RequestMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

enum ContentType: String {
    case APP_JSON = "application/json"
    case MULTIPART = "multipart/form-data; boundary="
}

class BaseApi: NSObject {
    
    var defaultSession = URLSession()
    
    override init() {
        super.init()

        defaultSession = URLSession(configuration: .default)
    }
    
    func createSyncDataTask(_ request: URLRequest) -> Data? {
        
        return defaultSession.synchronousDataTask(with: request).0
    }
    
    func createDataTask<T: Codable>(_ request: URLRequest, handler: @escaping(BaseResponseModel<T>)->()) {
        let dataTask = defaultSession.dataTask(with: request, completionHandler: { data, response, error in
            
            let str = String(decoding: data!, as: UTF8.self)
            let model: BaseResponseModel<T> = self.baseCompletionHandler(data: data, urlResponse: response, error: error)
            
            DispatchQueue.main.async {
                handler(model)
            }
            
        })
        dataTask.resume()
    }
    
    private func baseCompletionHandler<T: Codable>(data: Data?, urlResponse: URLResponse?, error: Error?) -> BaseResponseModel<T> {
        if let error = error {
            StytchLog.show("Server error:", error)
            return BaseResponseModel<T>(ErrorResponseModel())
        } else if let data = data {
            
            StytchLog.show("Response:", String(data: data, encoding: String.Encoding.utf8)!)
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let model = try jsonDecoder.decode(T.self, from: data)
                return BaseResponseModel<T>(model)
            } catch let parseError {
                StytchLog.show("Parse error:", parseError)
            }
            
            do {
                let errorModel = try jsonDecoder.decode(ErrorResponseModel.self, from: data)
                return BaseResponseModel<T>(errorModel)
            } catch {
                
            }
            
        }
        
        return BaseResponseModel<T>(ErrorResponseModel())
    }
    
}


extension URLRequest {

    /**
     Returns a cURL command representation of this URL request.
     */
    public var curlString: String {
        guard let url = url else { return "" }
        var baseCommand = #"curl "\#(url.absoluteString)""#

        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }

}
