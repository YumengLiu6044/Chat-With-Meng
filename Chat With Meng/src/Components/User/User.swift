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

struct User: Codable, Hashable, Identifiable {
    var email: String = ""
    @DocumentID var id: String? = nil
    var profilePicURL: URL = URL(fileURLWithPath: "default")
    var userName: String = ""

    var friends: [Friend] = []
    var friendRequests: [String] = []
    
    var humanNotifications: Bool = true
    var AiNotifications: Bool = false
    
    var profileOverlayData: [CGFloat] = []
    
    enum CoodingKey: String, CodingKey {
        case email
        case uid
        case profilePicURL
        case userName
        case friends
        case friendRequests
        case humanNotifications
        case AiNotifications
        case profileOverlayData
    }

}
