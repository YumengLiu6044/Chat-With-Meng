//
//  FriendsViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/16/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var toast:           Toast?      = nil
    
    @Published var currentFriendsListener: ListenerRegistration? = nil
    @Published var currentFriendRequestListener: ListenerRegistration? = nil
    
    @Published var friendSearchResult: [Friend] = []
    @Published var friendRequests:     [Friend] = []
    @Published var friends:            [Friend] = []
    @Published var friendRemovalQueue:       [Friend] = []
    @Published var requestRemovalQueue:      [Friend] = []
    
    @Published var rowState:     FriendRowState = .friended
    
    @Published var friendInView: Friend                 = Friend()
    
    @Published var currentUser:     User        = User()
    
    @Published var showProfile:     Bool = false
    
    public func removeListeners() {
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
                                if let result = self?.friendSearchResult.contains(friendData) {
                                    if result {
                                        self?.friendSearchResult.removeAll {$0 == friendData}
                                        self?.toast = Toast(
                                            style: .success,
                                            message: "\(friendData.userName) has accepted your friend request"
                                        )
                                    }
                                    
                                }
                            }
                            
                        case .removed:
                            if friendData == self?.friendInView {
                                self?.showProfile = false
                                self?.friendRemovalQueue.append(friendData)
                            }
                            else {
                                self?.removeFriendFromLocal(friendData)
                            }
                            
                            
                        case .modified:
                            guard let modifiedIndex = self?.friends.firstIndex(where: {$0 == friendData}) else {return}
                            withAnimation(.smooth) {
                                self?.friends[modifiedIndex].notifications = friendData.notifications
                            }
                            
                            guard let modifiedAtResult = self?.friendSearchResult.firstIndex(where: {$0 == friendData}) else {return}
                            withAnimation(.smooth) {
                                self?.friendSearchResult[modifiedAtResult].notifications = friendData.notifications
                            }
                            
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
                                if friendData == self?.friendInView {
                                    self?.showProfile = false
                                    self?.requestRemovalQueue.append(friendData)
                                }
                                else {
                                    self?.removeFriendRequestFromLocal(friendData)
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
    
    init() {
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
    
    public func updateFriendByKeyVal(for friend: String, _ key: FriendRef.keys, _ val: Any) {
        guard let currentUID = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let friendRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(currentUID)
            .collection(FirebaseConstants.friends)
            .document(friend)
        
        friendRef.updateData([key.rawValue : val])
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
                guard let dataID = data.id else {continue}
                let friend = Friend(
                    email: data.email,
                    userID: dataID,
                    profilePicURL: data.profilePicURL,
                    userName: data.userName,
                    notifications: data.humanNotifications,
                    profileOverlayData: data.profileOverlayData
                )
                if let index = self.friends.firstIndex(where: {$0 == friend}) {
                    withAnimation(.smooth) {
                        self.friendSearchResult.append(self.friends[index])
                    }
                    continue
                }
                withAnimation(.smooth) {
                    self.friendSearchResult.append(friend)
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
        self.sortSearchResult()
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
        
        let friendData = Friend(userID: id)
        if friendData == self.friendInView {
            self.showProfile = false
            self.requestRemovalQueue.append(friendData)
        }
        else {
            self.removeFriendRequestFromLocal(friendData)
        }
        
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
            try friendDoc.setData(from: friendRef)
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    public func addFriend(from friendID: String) async {
        guard let local_uid = self.currentUser.id else {return}
        let friendRef = self.makeFriendRef(from: friendID)
        await self.removeFriendRequest(at: friendRef.id)
        
        self.addFriendToCloud(for: local_uid, friend: friendRef)
        
        let localAsFriend = self.makeFriendRef(from: local_uid)
        self.addFriendToCloud(for: friendRef.id, friend: localAsFriend)
    }
    
    public func removeFriendFromLocal(_ friend: Friend) {
        withAnimation(.smooth) {
            self.friends.removeAll {$0 == friend}
            self.friendSearchResult.removeAll {$0 == friend}
        }
        self.friendRemovalQueue.removeAll {$0 == friend}
        
    }
    
    public func removeFriendRequestFromLocal(_ friend: Friend) {
        withAnimation(.smooth) {
            self.friendRequests.removeAll {$0 == friend}
            self.friendSearchResult.removeAll {$0 == friend}
        }
        self.requestRemovalQueue.removeAll {$0 == friend}
    }
    
    public func unfriend(_ friend: Friend) async {
        guard let localUID = self.currentUser.id else {return}
        
        let friendDocRef = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(localUID)
            .collection(FirebaseConstants.friends)
            .document(friend.userID)
        
        let friendRefToLocal = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(friend.userID)
            .collection(FirebaseConstants.friends)
            .document(localUID)
        
        do {
            try await friendDocRef.delete()
            try await friendRefToLocal.delete()
        }
        catch {
            print("Error removing friend")
        }
    }

}
