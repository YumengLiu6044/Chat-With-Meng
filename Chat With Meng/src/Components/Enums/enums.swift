import SwiftUI

enum ChatViewSelection : Hashable {
    case messages, friends, settings
}

struct FirebaseConstants {
    static let users = "users"
    static let friends = "friends"
    static let friendRequests = "friendRequests"
    static let chats = "chats"
    static let incomingChats = "incomingChats"
    static let chatLogs = "chatLogs"
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
    case groupName
}

enum FriendRowState: String {
    case requested, friended, searched
    
    var buttonOne: String {
        switch self {
        case .requested:
            return "Accept"
        case .friended:
            return "Unfriend"
        case .searched:
            return "Friend"
        }
    }
    
    var buttonTwo: String {
        switch self {
        case .requested:
            return "Reject"
        
        case .friended:
            return "Unfriend"
        
        case .searched:
            return "Friend"
        }
    }
    
    var buttonOneStyle: Color {
        switch self {
        case .requested:
            return .blue
        case .friended:
            return .red
        case .searched:
            return .blue
        }
    }
    
    var buttonTwoStyle: Color {
        switch self {
        case .requested:
            return .red
        case .friended:
            return .red
        case .searched:
            return .blue
        }
    }
}

enum ContentType: String, Codable {
    case text = "text"
    case image = "image"
    case video = "video"
}
