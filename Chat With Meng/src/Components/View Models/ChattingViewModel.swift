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
    
    @Published var chatMap : [ChatMapItem] = []
    
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
        loadChatsOnAppear()
    }
    
    private func handleNewIncomingMessage(message: Message) {
        
        let ref = ChatRef(chatID: message.chatID)
        
        do {
            try FirebaseManager.shared.firestore
                .collection(FirebaseConstants.users)
                .document(self.currentUserID)
                .collection(FirebaseConstants.chatsIncludingUser)
                .document(message.chatID)
                .setData(from: ref)
        }
        catch {
            print("Failed to update chat reference collection for userID: \(self.currentUserID)")
            return
        }
        
        self.removeIncomingMessage(message)
        
        switch message.contentType {
        case .text:
            guard let index = self.chatMap.firstIndex(where: {$0.chatID == message.chatID}) else {
                let newItem = ChatMapItem(chatID: message.chatID, chatLogs: [message])
                self.chatMap.append(newItem)
                return
            }
            self.chatMap[index].chatLogs.append(message)
            break
            
        case .image:
            // TODO: implement handling images
            break
        case .video:
            // TODO: implement handling videos
            break
        }
    }
    
    private func removeIncomingMessage(_ message: Message) {
        guard let messageID = message.id else {return}
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(self.currentUserID)
            .collection(FirebaseConstants.incomingChats)
            .document(messageID)
            .delete()
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
                        do {
                            let message = try change.document.data(as: Message.self)
                            self?.handleNewIncomingMessage(message: message)
                        }
                        catch {
                            print("Failed to decode message object")
                            return
                        }
                    default:
                        return
                    }
                }
                
            }
        self.incomingMessageListener = listener
    }
    
    public func removeListeners() {
        self.incomingMessageListener?.remove()
        self.incomingMessageListener = nil
        
    }
    
    private func loadChatLogs(forChat chatID: String, completion: @escaping ([Message]?) -> Void) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chats)
            .document(chatID)
            .collection(FirebaseConstants.chatLogs)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.toast = Toast(style: .error, message: error.localizedDescription)
                    return
                }
                guard let snapshot = snapshot else {return}
                
                var messageList: [Message] = []
                snapshot.documents.forEach { document in
                    do {
                        let data = try document.data(as: Message.self)
                        messageList.append(data)
                    }
                    catch {
                        print("Failed to load chats on appear")
                        return
                    }
                }
                return completion(messageList)
            }
    }
    
    public func loadChatsOnAppear() {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(self.currentUserID)
            .collection(FirebaseConstants.chatsIncludingUser)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.toast = Toast(style: .error, message: error.localizedDescription)
                    return
                }
                guard let snapshot = snapshot else {return}
                snapshot.documents.forEach { document in
                    do {
                        let data = try document.data(as: ChatRef.self)
                        self.loadChatLogs(forChat: data.chatID){
                            chatLogs in
                            guard let chatLogs = chatLogs else {return}
                            let mapItem = ChatMapItem(chatID: data.chatID, chatLogs: chatLogs)
                            self.chatMap.append(mapItem)
                        }
                    }
                    catch {
                        print("Failed to load chats on appear")
                        return
                    }
                }
            }
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
                return
            }
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
    
    public func processGroupChatCreation(with name: String, of members: [Friend]) {
        FirebaseManager.makeGroupChat(with: name, of: members) { toast in
            
            if toast.style == .success {
                self.showNewChat = false
                self.isComposing = false
                
                FirebaseManager.sendMessage(
                    fromSender: self.currentUserID,
                    toChat: toast.message,
                    contentType: .text,
                    content: "You have been invited to \(name)",
                    time: .now
                )
            }
            else {
                self.toast = toast
            }
        }
        
    }
    
}
