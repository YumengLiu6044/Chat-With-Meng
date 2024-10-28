import SwiftUI

enum ChatViewSelection : Hashable {
    case messages, friends, settings
}

struct FirebaseConstants {
    static let users = "users"
    static let friends = "friends"
    static let friendRequests = "friendRequests"
    
}


enum AppViewSelection: Hashable {
    case login, chat
}

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

enum FocusField: Hashable {
    case email, password, confirmPassword, passwordReset
}
