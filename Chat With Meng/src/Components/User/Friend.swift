//
//  User.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/9/24.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI



struct FriendRef: Codable {
    var id: String
    var notifications: Bool = true
    
    enum keys: String, CodingKey {
        case id
        case notifications
    }
    
}

struct Friend: Identifiable, Equatable {
    var email: String = ""
    var id: UUID = UUID()
    var userID: String = ""
    var profilePicURL: String = "https://img.decrypt.co/insecure/rs:fit:3840:0:0:0/plain/https://cdn.decrypt.co/wp-content/uploads/2024/05/doge-dogecoin-meme-kabosu-gID_7.jpg@webp"
    var userName: String = "Friend"
    var notifications: Bool = true
    var profileOverlayData: [CGFloat] = [0, 0, 0]
    
    static func ==(lhs: Friend, rhs: Friend) -> Bool {
        return lhs.id == rhs.id
    }
    
}
