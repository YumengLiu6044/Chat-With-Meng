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

struct User: Codable, Hashable {
    var email: String = ""
    @DocumentID var uid: String? = nil
    var profilePicURL: URL = URL(fileURLWithPath: "default")
    var userName: String = ""

    var friends: [Friend] = []
    var friendRequests: [String] = []
    
    var humanNotifications: Bool = true
    var AiNotifications: Bool = false
    
    var profileOverlayData: [CGFloat] = []

}
