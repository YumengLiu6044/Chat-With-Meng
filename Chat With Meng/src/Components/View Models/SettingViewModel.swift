//
//  SettingViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/29/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore


class SettingViewModel: ObservableObject {
    @Published var profilePic:      UIImage?    = nil
    @Published var currentUser: User            = User()
    @Published var showImagePicker: Bool        = false
    @Published var toast: Toast?                = nil
    
    init() {
        guard let currentID = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(currentID)
            .getDocument {
                document, error in
                if let error = error {
                    self.toast = Toast(style: .error, message: error.localizedDescription)
                }
                if let document = document {
                    do {
                        let data = try document.data(as: User.self)
                        self.currentUser = data
                    }
                    catch {
                        return
                    }
                    
                }
        }
    }
    
    public func updateProfilePic() -> Void {
        guard let uid = currentUser.id else {return}
        guard let profilePic = profilePic else {return}
        
        let path = [FirebaseConstants.users, uid, "profilePic"].joined(separator: "/")
        let colorData = profilePic.averageColor
        
        FirebaseManager.uploadPicture(picture: profilePic, at: path) {
            imgURL in
            if let imgURL = imgURL {
                self.currentUser.profilePicURL = imgURL.absoluteString
                self.currentUser.profileOverlayData = colorData
                self.updateCurrentUserByKeyVal(key: User.keys.profilePicURL, val: imgURL.absoluteString)
                self.updateCurrentUserByKeyVal(key: User.keys.profileOverlayData, val: colorData)
                
            }
        }
    }
    
    public func updateUserName(to newUserName: String, completion: @escaping (Error?) -> Void) {
        if (newUserName.isEmpty) {
            return completion(SettingError.userNameEmpty)
        }
        
        if (!newUserName.allSatisfy {$0.isLetter || $0.isNumber || $0.isWhitespace}) {
            return completion(SettingError.userNameInvalidCharacter)
        }
        if (newUserName.count > 15) {
            return completion(SettingError.userNameTooLong)
        }
        else {
            self.currentUser.userName = newUserName
            self.updateCurrentUserByKeyVal(key: User.keys.userName, val: newUserName)
            return completion(nil)
        }
    }
    
    public func updateCurrentUserByKeyVal(key: User.keys, val: Any) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let userDocRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
        
        userDocRef.updateData([key.rawValue: val])
    }
}
