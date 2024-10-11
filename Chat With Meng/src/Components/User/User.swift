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

class User {
    private var email: String
    private var uid: String
    private var profilePicURL: URL

    init(_ email: String, _ uid: String, _ profilePic: URL) {

        self.email = email
        self.uid = uid
        self.profilePicURL = profilePic

    }

    func getInfo() -> [String: Any] {
        return [
            "email": email,
            "uid": uid,
            "profileURL": profilePicURL,
        ]
    }

}
