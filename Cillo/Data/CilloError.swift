//
//  CilloError.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

// MARK: - Enums

enum CilloErrorType {
    case passwordIncorrect
    case usernameTaken
    case userUnauthenticated
    case boardNameInvalid
    case noJSON
    case unknown
    
    // MARK: - Initializers
    init(code: Int) {
        switch code {
        case 10: self = .userUnauthenticated
        case 20: self = .passwordIncorrect
        case 30: self = .usernameTaken
        case 40: self = .boardNameInvalid
        default: self = .unknown
        }
    }
    
    // MARK: - Properties
    
    var code: Int {
        switch self {
        case .userUnauthenticated: return 10
        case .passwordIncorrect: return 20
        case .usernameTaken: return 30
        case .boardNameInvalid: return 40
        case .noJSON: return .min
        case .unknown: return .max
        }
    }
}

// MARK: - Structs

struct CilloError: ErrorType {
    
    // MARK: - Properties
    
    let requestType: Router
    let errorType: CilloErrorType
    let description: String
    
    // MARK: - Initializers
    
    init(json: JSON, requestType: Router) {
        description = json["error"] != nil ? json["error"].stringValue : ""
        let code = json["code"] != nil ? json["code"].intValue : .max
        errorType = CilloErrorType(code: code)
        requestType = requestType
    }
    
    init(requestType: Router) {
        description = "Failed to parse JSON"
        errorType = .noJSON
        requestType = requestType
    }
    
    // MARK: - Helper Functions
    
    /// Shows this error's properties in a UIAlertView that pops up on the screen.
    func showAlert() {
        let alert = UIAlertView(title: "Error Code \(code)",
                                message: "\(description)\n\(requestTypeDescription)",
                                delegate: nil,
                                cancelButtonTitle: "OK")
        alert.show()
    }
}
