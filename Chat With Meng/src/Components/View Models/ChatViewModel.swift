//
//  ChatViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import Foundation
import SwiftUI

enum ChatViewSelection : Hashable {
    case messages, friends, settings
}

class ChatViewModel: ObservableObject {
    @Published var chatViewSelection: ChatViewSelection = .messages
    
    @Published var currentUser:     User        = User()
    @Published var toast:           Toast?      = nil
    @Published var profilePic:      UIImage?    = nil
    
    @Published var showImagePicker: Bool = false
    @Published var showMenu:        Bool = true
    
    public func switchTo(view toView: ChatViewSelection, after delay: Int = 0, animationLength length: CGFloat = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            withAnimation(.snappy(duration: TimeInterval(length))) {
                self.chatViewSelection = toView
            }
        })
    }
    
    public func initializeCurrentUser() -> Void {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument {
            document, error in
            if let error = error {
                self.toast = Toast(style: .error, message: error.localizedDescription)
            }
            else {
                if let document = document {
                    do {
                        self.currentUser = try document.data(as: User.self)
                        print(self.currentUser)
                    } catch {
                        self.toast = Toast(style: .error, message: "Error decoding document")
                    }
                }
                else {
                    self.toast = Toast(style: .error, message: "Error getting document")
                }
            }
        }
        
    }
    
    public func updateCurrentUser() {
        guard let uid = currentUser.uid else {return}
        do {
            try FirebaseManager.shared.firestore.collection("users").document(uid).setData(from: currentUser) {
                _ in
            }
        }
        catch {
            self.toast = Toast(style: .error, message: "Error updating current user info")
        }
    }
    
    public func updateProfilePic() -> Void {
        FirebaseManager.uploadProfilePic(profilePic: self.profilePic!) {
            imgURL, colorData in
            
            if let imgURL = imgURL, let colorData = colorData {
                self.currentUser.profilePicURL = imgURL
                self.currentUser.profileOverlayData = colorData
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
        if (newUserName.count > 30) {
            return completion(SettingError.userNameTooLong)
        }
        else {
            self.currentUser.userName = newUserName
            self.updateCurrentUser()
            return completion(nil)
        }
    }
}
