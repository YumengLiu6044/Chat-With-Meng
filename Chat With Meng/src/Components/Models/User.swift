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

struct User: Codable, Hashable, Identifiable, Equatable {
    var email: String = ""
    @DocumentID var id: String? = nil
    var profilePicURL: String = ""
    var userName: String = ""
    
    var humanNotifications: Bool = true
    var AiNotifications: Bool = false
    
    var profileOverlayData: [CGFloat] = []
    
    enum keys: String, CodingKey {
        case email
        case id
        case profilePicURL
        case userName
        case humanNotifications
        case AiNotifications
        case profileOverlayData
    }

}
