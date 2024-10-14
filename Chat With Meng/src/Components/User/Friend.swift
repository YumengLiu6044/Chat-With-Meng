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

struct Friend: Codable {
    var email: String = ""
    var uid: String = ""
    var profilePicURL: URL = URL(string: "https://img.decrypt.co/insecure/rs:fit:3840:0:0:0/plain/https://cdn.decrypt.co/wp-content/uploads/2024/05/doge-dogecoin-meme-kabosu-gID_7.jpg@webp") ?? URL(filePath: "default")
    var userName: String = "Friend"
    var notifications: Bool = true
    
}
