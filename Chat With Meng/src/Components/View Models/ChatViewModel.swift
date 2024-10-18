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

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chatViewSelection: ChatViewSelection = .messages
    
    @Published var currentUser:     User        = User()
    @Published var toast:           Toast?      = nil
    @Published var profilePic:      UIImage?    = nil
    
    @Published var showImagePicker: Bool = false
    @Published var showMenu:        Bool = true
    
    @Published var currentUserListener: ListenerRegistration? = nil
    
    @Published var friendSearchResult: [Friend] = []
    @Published var friendRequests:     [Friend] = []
    
    private var userDocRef: DocumentReference?
    
    private var isSearchingForUsers: Bool = false
    
    
    
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
    
    public func updateCurrentUserByKeyVal(key: User.CoodingKey, val: Any) {
        self.userDocRef?.updateData([key.rawValue: val])
    }
    
    
    
    public func updateProfilePic() -> Void {
        FirebaseManager.uploadProfilePic(profilePic: self.profilePic!) {
            imgURL, colorData in
            
            if let imgURL = imgURL, let colorData = colorData {
                self.currentUser.profilePicURL = imgURL.absoluteString
                self.currentUser.profileOverlayData = colorData
                self.updateCurrentUserByKeyVal(key: User.CoodingKey.profilePicURL, val: imgURL.absoluteString)
                self.updateCurrentUserByKeyVal(key: User.CoodingKey.profileOverlayData, val: colorData)
                
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
            self.updateCurrentUserByKeyVal(key: User.CoodingKey.userName, val: newUserName)
            return completion(nil)
        }
    }
    
    public func makeFriend(from id: String?, completion: @escaping (Friend?) -> Void) {
        guard let id = id else {return completion(nil)}
        
        FirebaseManager.shared.firestore.collection("users").document(id).getDocument {
            document, error in
            if let error = error {
                self.toast = Toast(style: .error, message: error.localizedDescription)
            }
            else {
                if let document = document {
                    do {
                        let data = try document.data(as: User.self)
                        
                        let dataAsFriend = Friend(
                            email: data.email,
                            id: data.id,
                            profilePicURL: data.profilePicURL,
                            userName: data.userName,
                            notifications: true,
                            profileOverlayData: data.profileOverlayData
                        )
                        return completion(dataAsFriend)
                        
                    } catch {
                        self.toast = Toast(style: .error, message: "Error decoding document")
                    }
                }
                else {
                    self.toast = Toast(style: .error, message: "Error getting document")
                }
            }
        }
        return completion(nil)
    }
    
    public func searchUsers(from searchKey: String) async {
        self.friendSearchResult = []
        if searchKey.isEmpty {
            isSearchingForUsers = false
            return
        }
        
        if isSearchingForUsers {
            return
        }
        else {
            isSearchingForUsers = true
        }
        
        do {
            let queryDocs = try await FirebaseManager.shared.firestore.collection("users")
                .whereField(User.CoodingKey.userName.rawValue, isGreaterThanOrEqualTo: searchKey)
                .whereField(User.CoodingKey.userName.rawValue, isLessThanOrEqualTo: searchKey + "~")
                .order(by: User.CoodingKey.userName.rawValue)
                .limit(to: 10)
                .getDocuments()
            
            for document in queryDocs.documents {
                let data = try document.data(as: User.self)
                if data.userName == self.currentUser.userName {
                    continue
                }
                
                var included: Bool = false
                for request in self.friendRequests {
                    if (request.id == data.id) {
                        included = true
                    }
                }
                if included {
                    continue
                }
                
                self.makeFriend(from: data.id) { friend in
                    guard let friend = friend else {return}
                    withAnimation(.smooth) {
                            self.friendSearchResult.append(friend)
                    }
                }
            }
        }
        catch {
            print(error.localizedDescription)
            
        }
    
        
        isSearchingForUsers = false
    }
    
    public func sendFriendRequenst(to userID: String?) {
        guard let userID = userID else { return }
        if userID == self.currentUser.id {
            return
        }
        guard let currentUserID: String = self.currentUser.id else {return }
        
        FirebaseManager.shared.firestore.collection("users").document(userID).updateData([User.CoodingKey.friendRequests.rawValue : FieldValue.arrayUnion([currentUserID])]) {
            error in
            if let error = error {
                self.toast = Toast(style: .error, message: error.localizedDescription)
                return
            }
            
            self.toast = Toast(style: .success, message: "Friend request sent")
            
        }
    }
    
    public func loadFriendRequests() {
        for request in self.currentUser.friendRequests {
            var shouldSkip = false
            for existing in self.friendRequests {
                if existing.id == request {
                    shouldSkip = true
                }
            }
            if shouldSkip {
                continue
            }
            self.makeFriend(from: request) { friend in
                guard let friend = friend else {return}
                withAnimation(.smooth){
                    self.friendRequests.append(friend)
                }
            }
        }
    }
    
    public func rejectFriendRequest(at id: String) {
        guard let uid = self.currentUser.id else { return }
        withAnimation(.smooth) {
            self.friendRequests.removeAll{$0.id == id}
        }
        FirebaseManager.shared.firestore.collection("users").document(uid)
            .updateData([
                User.CoodingKey.friendRequests.rawValue :
                    FieldValue.arrayRemove([id])
            ])
    }
    
    public func addFriendFromRequest(of uid: String, completion: @escaping (Bool) -> Void) async {
        
    }
}
