//
//  Chat.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/29/24.
//

import Firebase
import FirebaseFirestore
import SwiftUI

struct ChatRef : Codable {
    var chatID: String
    var notifications: Bool = true
    
    enum keys: String, CodingKey {
        case chatID
        case notifications
    }
}

struct Chat: Codable {
    @DocumentID var chatID: String? = nil
    var userIDArray: [String] = []
    var chatTitle: String = ""
    var chatCoverURL: String = ""
    var chatCoverOverlay: [CGFloat] = [0, 0, 0]
    
    enum keys : String, CodingKey {
        case chatID
        case userIDArray
        case chatTitle
        case chatCoverURL
        case chatCoverOverlay
    }
}

struct ChatMapItem: Identifiable, Equatable {
    var id: UUID = UUID()
    var chatID: String
    var chatLogs: [Message] = []
    
    static func ==(lhs: ChatMapItem, rhs: ChatMapItem) -> Bool {
        return lhs.chatID == rhs.chatID
    }
}
