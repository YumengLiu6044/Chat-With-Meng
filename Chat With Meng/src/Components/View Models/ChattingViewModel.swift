//
//  ChattingViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/28/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class ChattingViewModel: ObservableObject {
    @Published var showNewChat: Bool = false
    @Published var isComposing: Bool = false
    
    @Published var searchkey: String = ""
    
    @Published var chatMap : [String : [Message]] = ["":[]]
    
    @Published var recipientList: [Friend] = []
    @Published var searchResults: [Friend] = []
    
    @Published var toast: Toast? = nil
    
    private var currentUserID: String = ""
    private var incomingMessageListener: ListenerRegistration? = nil
    
    init() {
        guard let id = FirebaseManager.shared.auth.currentUser?.uid else {return}
        self.currentUserID = id
        
        // Start listener
        attachIncomingMessageListner()
    }
    
    private func attachIncomingMessageListner() {
        let listener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(self.currentUserID)
            .collection(FirebaseConstants.incomingChats)
            .addSnapshotListener(includeMetadataChanges: true) {
                [weak self]
                snapshot, error in
                if let error = error {
                    self?.toast = Toast(style: .error, message: error.localizedDescription)
                    return
                }
                guard let snapshot = snapshot else {return}
                snapshot.documentChanges.forEach { change in
                    switch change.type {
                    case .added:
                        print("Added message")
                    default:
                        return
                    }
                }
                
            }
    }
    
    public func removeListeners() {
        
    }
    
    private func loadChatsOnLoad() {
        
    }
    
    func searchForFriends(from friends: [Friend]) {
        self.searchResults = []
        
        for friend in friends where
        friend.userName.lowercased().contains(searchkey.lowercased()){
            withAnimation(.smooth) {
                self.searchResults.append(friend)
            }
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
    
    public func moveSearchResultToRecipient(for friend: Friend) {
        withAnimation(.smooth) {
            searchResults.removeAll {$0 == friend}
            if !recipientList.contains(friend) {
                recipientList.append(friend)
            }
        }
    }
    
    public func moveRecipientToSearchResult(for friend: Friend) {
        withAnimation(.smooth) {
            recipientList.removeAll {$0 == friend}
            if !searchResults.contains(friend) {
                searchResults.append(friend)
            }
        }
    }
    
    private func chatExists(of members: [String]) async -> Bool {
        let query = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chats)
            .whereField(Chat.keys.userIDArray.rawValue, isEqualTo: members)
        
        do {
            let docs = try await query.getDocuments()
            return docs.count > 0
        }
        catch {
            return false
        }
    }
    
    public func getMembers(completion: @escaping ([Friend]?) -> Void)  {
        var total = self.recipientList
        self.makeFriend(from: self.currentUserID) { friend in
            guard let friend = friend else {return completion(nil)}
            total.append(friend)
            return completion(total)
        }
    }
    
    public func processSendButtonClick() async{
        var chatMembers: [String] = self.recipientList.compactMap { friend in
            return friend.userID
        }
        chatMembers.append(self.currentUserID)
        
        if await !chatExists(of: chatMembers) {
            self.showNewChat = true
        }
    }
    
    public func makeGroupChat(with name: String, of members: [Friend], completion: @escaping (Bool) -> Void) {
        if (name.isEmpty) {
            return completion(false)
        }
        if (name.allSatisfy {$0.isWhitespace}) {
            toast = Toast(style: .error, message: "At least one non-space character is required")
            return completion(false)
        }
        if (!name.allSatisfy {$0.isLetter || $0.isNumber || $0.isWhitespace}) {
            toast = Toast(style: .error, message: "Only alpha-numeric characters and spaces are allowed")
            return completion(false)
        }
        if (name.count > 30) {
            toast = Toast(style: .error, message: "The maximum character count is 30")
            return completion(false)
        }
        
        uploadToFirestore(
            members: members,
            name: name,
            completion: completion
        )
    }
    
    private func uploadToFirestore(members: [Friend], name: String, completion: @escaping (Bool) -> Void) {
        let chat = Chat (
            chatID: nil,
            userIDArray: members.compactMap {$0.userID},
            chatTitle: name
        )
        
        do {
            try FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chats)
                .addDocument(from: chat) {
                    error in
                    if let error = error {
                        self.toast = Toast(style: .error, message: error.localizedDescription)
                        return completion(false)
                    }
                    else {
                        self.toast = Toast(style: .success, message: "You have made the \"\(name)\"")
                        return completion(true)
                    }
                }
            
        }
        catch {
            toast = Toast(style: .error, message: "Failed to make new chat")
            return completion(false)
        }
    }
    
}
