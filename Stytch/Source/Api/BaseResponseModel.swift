//
//  BaseResponseModel.swift
//
//  Copyright © 2020 Logicants. All rights reserved.
//

import Foundation


class BaseResponseModel<T: Codable> {

    var data: T?
    var error = ErrorResponseModel()
    
    enum DataKeys: String, CodingKey {
        case data
        case status
    }
    
    enum ErrorKeys: String, CodingKey {
        case status
        case errorType = "error_type"
    }
    
    init(_ dataModel: T) {
        data = dataModel
    }
    
    init(_ errorModel: ErrorResponseModel) {
        data = nil
        error = errorModel
    }
}

struct EmptyModel: Codable {
}
