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
    @Published var showMessageView: Bool = false
    
    @Published var searchkey: String = ""
    @Published var messageText: String = ""
    
    @Published var chatMap : [ChatMapItem] = []
    
    @Published var recipientList: [Friend] = []
    @Published var searchResults: [Friend] = []
    
    @Published var toast: Toast? = nil
    
    @Published var chatObjInView: Chat = Chat()
    
    private var currentUserID: String = ""
    private var incomingMessageListener: ListenerRegistration? = nil
    
    init() {
        guard let id = FirebaseManager.shared.auth.currentUser?.uid else {return}
        self.currentUserID = id
        
        loadChatsOnAppear()
        
        // Start listener
        attachIncomingMessageListner()
        
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
                let newItem = ChatMapItem(chatID: message.chatID, mostRecent: message)
                withAnimation(.smooth) {
                    self.chatMap.insertSorted(newItem: newItem)
                }
                return
            }
            withAnimation(.smooth) {
                let current = self.chatMap[index].mostRecent
                self.chatMap[index].mostRecent = min(current, message)
            }
            self.chatMap.sort{$0.mostRecent < $1.mostRecent}
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
    
    private func loadChatLogs(forChat chatID: String, limit: Int = 1000, completion: @escaping ([Message]?) -> Void) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chats)
            .document(chatID)
            .collection(FirebaseConstants.chatLogs)
            .order(by: Message.keys.time.rawValue, descending: true)
            .limit(to: limit)
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
                        self.loadChatLogs(forChat: data.chatID, limit: 1){
                            chatLogs in
                            guard let chatLogs = chatLogs else {return}
                            let mapItem = ChatMapItem(chatID: data.chatID, mostRecent: chatLogs.first ?? Message(contentType: .text, content: "No message exists"))
                            withAnimation(.smooth) {
                                self.chatMap.insertSorted(newItem: mapItem)
                            }
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
    
    public func countUnreadMessages() -> Int {
        return self.chatMap.count(where: {!$0.mostRecent.isRead})
    }
    
    public func timeAgoDescription(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
        let dateFormatter = DateFormatter()
        
        if let week = components.weekOfYear, week > 0 {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: date)
        }
        
        if let day = components.day {
            switch day {
            case 0:
                dateFormatter.dateFormat = "h:mm a"
                return dateFormatter.string(from: date)
                
            case 1:
                return "Yesterday"
                
            default:
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: date)
            }
        }
        return date.formatted(.iso8601)
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
    
    private func chatExists(of members: [String]) async -> Chat? {
        let query = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chats)
            .whereField(Chat.keys.userIDArray.rawValue,
                        isEqualTo: Dictionary(uniqueKeysWithValues: members.map { ($0, "") }))
        
        do {
            guard let docs = try await query.getDocuments().documents.first
            else {
                return nil
            }
            let firstData = try docs.data(as: Chat.self)
            return firstData
        }
        catch {
            return nil
        }
    }
    
    public func getMembers() async -> [Friend]? {
        var total = self.recipientList
        guard let friend = await FirebaseManager.makeFriend(from: self.currentUserID) else
        {
            return nil
        }
        total.append(friend)
        return total
    }
    
    public func processSendButtonClick() async{
        var chatMembers: [String] = self.recipientList.compactMap { friend in
            return friend.userID
        }
        chatMembers.append(self.currentUserID)
        
        if let chatObj = await chatExists(of: chatMembers) {
            self.chatObjInView = chatObj
            self.showMessageView = true
            self.isComposing = false
        }
        else {
            self.showNewChat = true
        }
    }
    
    public func processAirPlaneButtonPress(friend: Friend) async {
        let chatMembers = [self.currentUserID, friend.userID]
        
        if let chatObj = await chatExists(of: chatMembers) {
            self.chatObjInView = chatObj
            self.showMessageView = true
            self.isComposing = false
        }
        else {
            guard let selfAsFriend =  await FirebaseManager.makeFriend(from: self.currentUserID)
            else {return}
            let members = [selfAsFriend, friend]
            await self.processGroupChatCreation(with: friend.userName, of: members, sendWelcomeMessage: false)
        }
        
    }
    
    public func processGroupChatCreation(with name: String, of members: [Friend], sendWelcomeMessage: Bool = true) async {
        let (toast, chat) = await FirebaseManager.makeGroupChat(with: name, of: members)
        if toast.style == .success, let chat = chat {
            withAnimation(.smooth) {
                self.showNewChat = false
                self.isComposing = false
                self.chatObjInView = chat
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showMessageView = true
                }
            }
            
            if !sendWelcomeMessage {
                return
            }
            
            await FirebaseManager.sendMessage(
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
    
    public func handleOnChatRowDelete(_ index: Int) {
        if !chatMap.indices.contains(index) {
            self.toast = Toast(style: .error, message: "ChatMap doesn't include index: \(index)")
            return
        }
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(self.currentUserID)
            .collection(FirebaseConstants.chatsIncludingUser)
            .document(self.chatMap[index].chatID)
            .delete {
                error in
                if let error = error {
                    self.toast = Toast(style: .error, message: error.localizedDescription)
                    return
                }
                self.chatMap.remove(at: index)
            }
    }
    
    public func loadChatOnAppear(fromChat chatID: String) async {
        guard let chatObj = await FirebaseManager.makeChatObject(fromID: chatID)
        else {return}
        
        self.chatObjInView = chatObj
    }
    
    public func determineCoverPic(forChat chatObj: Chat) async -> (String, [CGFloat]) {
        if !chatObj.chatCoverURL.isEmpty {
            return (chatObj.chatCoverURL, chatObj.chatCoverOverlay)
        }
        if chatObj.userIDArray.count == 2 {
            guard let other = chatObj.userIDArray.first(where: {$0.key != self.currentUserID})?.key else {
                return ("", [0, 0, 0])
            }
            do {
                let document = try await FirebaseManager.shared.firestore
                    .collection(FirebaseConstants.users)
                    .document(other)
                    .getDocument(as: User.self)
                return (document.profilePicURL, document.profileOverlayData)
            }
            catch {
                print(error.localizedDescription.localizedLowercase)
                return ("", [0, 0, 0])
            }
                
        }
        
        return ("", [0, 0, 0])
    }
    
    public func markAsRead(inChat chatID: String) {
        guard let index = self.chatMap.first(where: {$0.chatID == chatID}) else {return}
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chats)
            .document(chatID)
            .collection(FirebaseConstants.chatLogs)
    }
}
