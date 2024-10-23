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

struct FirebaseConstants {
    static let users = "users"
    static let friends = "friends"
    static let friendRequests = "friendRequests"
    
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chatViewSelection: ChatViewSelection = .messages
    @Published var friendInView: Friend                 = Friend()
    
    @Published var currentUser:     User        = User()
    @Published var toast:           Toast?      = nil
    @Published var profilePic:      UIImage?    = nil
    
    @Published var showImagePicker: Bool = false
    @Published var showMenu:        Bool = true
    @Published var showProfile:     Bool = false
    
    @Published var currentFriendsListener: ListenerRegistration? = nil
    @Published var currentFriendRequestListener: ListenerRegistration? = nil
    
    @Published var friendSearchResult: [Friend] = []
    @Published var friendRequests:     [Friend] = []
    @Published var friends:            [Friend] = []
    @Published var removalQueue:       [Friend] = []
    
    @Published var rowState:     FriendRowState = .friended
    
    
    public func switchTo(view toView: ChatViewSelection, after delay: Int = 0, animationLength length: CGFloat = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            withAnimation(.snappy(duration: TimeInterval(length))) {
                self.chatViewSelection = toView
            }
        })
    }
    
    public func deinitializeCurrentUser() {
        self.currentFriendsListener?.remove()
        self.currentFriendRequestListener?.remove()
        
        self.currentFriendsListener = nil
        self.currentFriendRequestListener = nil
    }
    
    private func listenToFriends() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let friendsRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .collection(FirebaseConstants.friends)
        
        let listener = friendsRef.addSnapshotListener(includeMetadataChanges: true) { [weak self] querySnapshot, error in
            if let error = error {
                self?.toast = Toast(style: .error, message: error.localizedDescription)
                return
            }
            guard let querySnapshot = querySnapshot else {return}
            
            // Update local friends
            querySnapshot.documentChanges.forEach {
                change in
                do {
                    let friendRef = try change.document.data(as: FriendRef.self)
                    
                    self?.makeFriend(from: friendRef.id, notifications: friendRef.notifications) {
                        friendData in
                        guard let friendData = friendData else {return}
                        switch change.type {
                        case .added:
                            withAnimation(.smooth) {
                                self?.friends.append(friendData)
                                self?.friendSearchResult.removeAll {$0 == friendData}
                            }
                            
                        case .removed:
//                            withAnimation(.smooth) {
//                                self?.friends.removeAll {$0 == friendData}
//                                self?.friendSearchResult.removeAll {$0 == friendData}
//                            }
//                            return
                            if friendData == self?.friendInView {
                                self?.showProfile = false
                                self?.removalQueue.append(friendData)
                            }
                            else {
                                self?.removeFriendFromLocal(friendData)
                            }
                            
                            
                        case .modified:
//                            guard let modifiedIndex = self?.friends.firstIndex(where: {$0 == friendData}) else {return}
//                            withAnimation(.smooth) {
//                                self?.friends[modifiedIndex] = friendData
//                            }
//                            
//                            guard let modifiedAtResult = self?.friendSearchResult.firstIndex(where: {$0 == friendData}) else {return}
//                            withAnimation(.smooth) {
//                                self?.friendSearchResult[modifiedAtResult] = friendData
//                            }
                            
                            return
                            
                        default:
                            return
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        self.currentFriendsListener = listener
    }
    
    private func listenToRequests() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let friendRequestRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .collection(FirebaseConstants.friendRequests)
        
        let listener = friendRequestRef.addSnapshotListener(includeMetadataChanges: true) { [weak self] querySnapshot, error in
            if let error = error {
                self?.toast = Toast(style: .error, message: error.localizedDescription)
                return
            }
            guard let querySnapshot = querySnapshot else {return}
            
            // Update local friend requests
            querySnapshot.documentChanges.forEach {
                change in
                do {
                    let friendRefData = try change.document.data(as: FriendRef.self)
                    self?.makeFriend(from: friendRefData.id) {
                        friendData in
                        guard let friendData = friendData else {return}
                        switch change.type {
                            case .added:
                                withAnimation(.smooth) {
                                    self?.friendRequests.append(friendData)
                                }
                                return
                                
                            case .removed:
                                withAnimation(.smooth) {
                                    self?.friendRequests.removeAll {$0 == friendData}
                                    self?.friendSearchResult.removeAll {$0 == friendData}
                                }
                                return
                                
                            case .modified:
                                return
                                
                            default:
                                return
                        }
                    }
                }
                catch {
                    print("Error while doing stuff")
                }
            }
        }
        self.currentFriendRequestListener = listener
    }
    
    public func initializeCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let userDocRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
        
        userDocRef.getDocument {
            document, error in
            if let _ = error {
                print("Error fetching current user")
                return
            }
            if let document = document {
                do {
                    self.currentUser = try document.data(as: User.self)
                }
                catch {
                    print("Error decoding user")
                }
            }
            
        }
        self.listenToFriends()
        self.listenToRequests()
        
    }
    
    public func updateCurrentUserByKeyVal(key: User.keys, val: Any) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let userDocRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
        
        userDocRef.updateData([key.rawValue: val])
    }
    
    public func updateFriendByKeyVal(for friend: String, _ key: FriendRef.keys, _ val: Any, completion: @escaping () -> Void) {
        guard let currentUID = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let friendRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(currentUID)
            .collection(FirebaseConstants.friends)
            .document(friend)
        
        friendRef.updateData([key.rawValue : val]) {
            _ in
            return completion()
        }
    }
    
    public func updateProfilePic() -> Void {
        FirebaseManager.uploadProfilePic(profilePic: self.profilePic!) {
            imgURL, colorData in
            
            if let imgURL = imgURL, let colorData = colorData {
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
        if (newUserName.count > 30) {
            return completion(SettingError.userNameTooLong)
        }
        else {
            self.currentUser.userName = newUserName
            self.updateCurrentUserByKeyVal(key: User.keys.userName, val: newUserName)
            return completion(nil)
        }
    }
    
    public func makeFriend(from id: String?, notifications: Bool = true, completion: @escaping (Friend?) -> Void) {
        guard let id = id else {return completion(nil)}
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(id)
            .getDocument {
            document, error in
            
            if let error = error {
                self.toast = Toast(style: .error, message: error.localizedDescription)
            }
            else {
                if let document = document {
                    do {
                        let data = try document.data(as: User.self)
                        guard let friendID = data.id else {return}
                        let dataAsFriend = Friend(
                            email: data.email,
                            userID: friendID,
                            profilePicURL: data.profilePicURL,
                            userName: data.userName,
                            notifications: notifications,
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
    
    private func makeFriendRef(from friendID: String) -> FriendRef {
        let friendRef = FriendRef(id: friendID, notifications: true)
        return friendRef
    }
    public func sortSearchResult() {
        self.friendSearchResult.sort { lhs, rhs in
            let lhsRank = (self.friends.contains(lhs) ? 0 : self.friendRequests.contains(lhs) ? 1 : 2)
            let rhsRank = (self.friends.contains(rhs) ? 0 : self.friendRequests.contains(rhs) ? 1 : 2)
            
            if lhsRank != rhsRank {
                return lhsRank < rhsRank
            } else {
                return lhs.userName < rhs.userName
            }
        }

    }
    
    @MainActor
    private func searchByKey(from searchKey: String) async {
        do {
            let queryDocs = try await FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
                .whereField(User.keys.userName.rawValue, isGreaterThanOrEqualTo: searchKey)
                .whereField(User.keys.userName.rawValue, isLessThanOrEqualTo: searchKey + "~")
                .order(by: User.keys.userName.rawValue)
                .limit(to: 10)
                .getDocuments()
            
            for document in queryDocs.documents {
                let data = try document.data(as: User.self)
                if data.userName == self.currentUser.userName {
                    continue
                }
                self.makeFriend(from: data.id) { friend in
                    guard let friend = friend else {return}
                    withAnimation(.smooth) {
                        self.friendSearchResult.append(friend)
                    }
                    self.sortSearchResult()
                }
                
            }
        }
        catch {
            print(error.localizedDescription)
            
        }
    }
    
    public func searchUsers(from searchKey: String) async {
        self.friendSearchResult = []
        await self.searchByKey(from: searchKey.lowercased())
        await self.searchByKey(from: searchKey.uppercased())
        
    }
    
    public func sendFriendRequest(to userID: String?) {
        guard let userID = userID else { return }
        guard let currentUserID: String = self.currentUser.id else {return }
        if userID == currentUserID {
            return
        }
        
        let friendRequestRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(userID)
            .collection(FirebaseConstants.friendRequests)
            .document(currentUserID)
        
        let friendObj = self.makeFriendRef(from: currentUserID)
        do {
            try friendRequestRef.setData(from: friendObj) {
                error in
                if let error = error {
                    self.toast = Toast(style: .error, message: error.localizedDescription)
                    return
                }
                self.toast = Toast(style: .success, message: "Friend request sent")
            }
        }
        catch {
            print("failed to encode current user")
            return
        }
    }
    
    public func removeFriendRequest(at id: String) async {
        guard let uid = self.currentUser.id else { return }
        let docRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .collection(FirebaseConstants.friendRequests)
            .document(id)
        print("Deleting \(uid)'s friend at \(id)")
        
        do {
            try await docRef.delete()
        }
        catch {
            return
        }

    }
    
    private func addFriendToCloud(for uid: String?, friend friendRef: FriendRef) {
        guard let uid = uid else {return}
        
        let friendDoc = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .collection(FirebaseConstants.friends)
            .document(friendRef.id)
        
        do {
            try friendDoc.setData(from: friendRef) {
                error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    public func addFriend(from friendID: String) async {
        guard let local_uid = self.currentUser.id else {return}
        let friendRef = self.makeFriendRef(from: friendID)
        
        // Remove request from User.friendRequests
        await self.removeFriendRequest(at: friendRef.id)
        
        // Make friend for local user
        self.addFriendToCloud(for: local_uid, friend: friendRef)
        
        let localAsFriend = self.makeFriendRef(from: local_uid)
        self.addFriendToCloud(for: friendRef.id, friend: localAsFriend)
        
    }
    
    public func removeFriendFromLocal(_ friend: Friend) {
        withAnimation(.smooth) {
            self.friends.removeAll(where: {$0 == friend})
            self.friendSearchResult.removeAll(where: {$0 == friend})
        }
        self.removalQueue.removeAll(where: {$0 == friend})
        
    }

}
