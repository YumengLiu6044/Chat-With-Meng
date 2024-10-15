//
//  ChatViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

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
    
    @Published var currentUserListener: ListenerRegistration? = nil
    
    private var userDocRef: DocumentReference?
    
    public func switchTo(view toView: ChatViewSelection, after delay: Int = 0, animationLength length: CGFloat = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            withAnimation(.snappy(duration: TimeInterval(length))) {
                self.chatViewSelection = toView
            }
        })
    }
    
    public func deinitializeCurrentUser() {
        self.currentUserListener?.remove()
    }
    
    public func initializeCurrentUser(completion: @escaping (_ user: User) -> Void) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        self.userDocRef = FirebaseManager.shared.firestore.collection("users").document(uid)
        
//        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument {
//            document, error in
//            if let error = error {
//                self.toast = Toast(style: .error, message: error.localizedDescription)
//            }
//            else {
//                if let document = document {
//                    do {
//                        self.currentUser = try document.data(as: User.self)
//                        print(self.currentUser)
//                    } catch {
//                        self.toast = Toast(style: .error, message: "Error decoding document")
//                    }
//                }
//                else {
//                    self.toast = Toast(style: .error, message: "Error getting document")
//                }
//            }
//        }
        let listener = self.userDocRef?.addSnapshotListener(includeMetadataChanges: true) { [weak self] querySnapshot, error in
            if let error = error {
                self?.toast = Toast(style: .error, message: error.localizedDescription)
                return
            }
            
            guard let document = try? querySnapshot?.data(as: User.self) else {return}
            completion(document)
            
        }
        
        self.currentUserListener = listener
        
    }
    
    public func updateCurrentUser() {
        guard let uid = currentUser.uid else {return}
        
        do {
            try self.userDocRef?.setData(from: self.currentUser) {
                error in
                print(error?.localizedDescription ?? "")
            }
        }
        catch {
            self.toast = Toast(style: .error, message: "Failed to update current user")
        }
    }
    
    public func updateProfilePic() -> Void {
        FirebaseManager.uploadProfilePic(profilePic: self.profilePic!) {
            imgURL, colorData in
            
            if let imgURL = imgURL, let colorData = colorData {
                self.currentUser.profilePicURL = imgURL
                self.currentUser.profileOverlayData = colorData
                self.updateCurrentUser()
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
