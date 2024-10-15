//
//  Errors.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/14/24.
//

import Foundation

enum SettingError: Error {
    case userNameEmpty
    case userNameInvalidCharacter
    case userNameTooLong
    
    var description: String {
        let message: String
        
        switch (self) {
        case .userNameEmpty:
            message = "User name can't be empty"
        
        case .userNameInvalidCharacter:
            message = "User name should only contain letters, spaces, or numbers"
        
        case .userNameTooLong:
            message = "The user name is longer than 30 characters"
        }
        return message
    }
}
