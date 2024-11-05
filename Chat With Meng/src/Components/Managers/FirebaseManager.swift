import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Firebase


class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firebase.Firestore.firestore()
        super.init()
    }
    
    static public func uploadPicture(picture: UIImage, at path: String, _ quality: Double = 0.1, completion: @escaping (URL?) -> Void) {
        let ref = FirebaseManager.shared.storage.reference(withPath: path)
        guard let imageData = picture.jpegData(compressionQuality: quality)
        else { return }

        ref.putData(imageData) {
            metadata, error in

            if let error = error {
                print(error.localizedDescription)
                return
            }
            ref.downloadURL {
                imgURL, err in
                if let error = err {
                    print(error.localizedDescription)
                    return
                }
                if let imgURL = imgURL {
                    return completion(imgURL)
                }
            }
        }
    }
    
    static func makeGroupChat(with name: String, of members: [Friend]) async -> (Toast, Chat?) {
        if (name.isEmpty) {
            let toast = Toast(style: .error, message: "Name is empty")
            return (toast, nil)
        }
        if (name.allSatisfy {$0.isWhitespace}) {
            let toast = Toast(style: .error, message: "At least one non-space character is required")
            return (toast, nil)
        }
        if (!name.allSatisfy {$0.isLetter || $0.isNumber || $0.isWhitespace}) {
            let toast = Toast(style: .error, message: "Only alpha-numeric characters and spaces are allowed")
            return (toast, nil)
        }
        if (name.count > 30) {
            let toast = Toast(style: .error, message: "The maximum character count is 30")
            return (toast, nil)
        }
        let chat = Chat (
            chatID: nil,
            userIDArray: Dictionary(uniqueKeysWithValues: members.map { ($0.userID, "") }),
            chatTitle: name
        )
        
        guard let chatID = await uploadChatDataToFirestore(chat: chat)
        else {
            let toast = Toast(style: .error, message: "Failed to upload chat data")
            return (toast, nil)
        }
        
        let toast = Toast(style: .success, message: chatID)
        return (toast, chat)
    }
    
    static private func uploadChatDataToFirestore(chat: Chat) async -> String? {
        do {
            let docRef = try FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chats)
                .addDocument(from: chat)
            return docRef.documentID
            
        }
        catch {
            return nil
        }
    }
    
    static func sendMessage(
        fromSender senderID: String,
        toChat chatID: String,
        contentType: ContentType,
        content: String,
        time: Date
    ) async {
        var message = Message(
            contentType: contentType,
            content: content,
            chatID: chatID,
            fromUserID: senderID
        )
        
        // Add message to chatLogs at chatID
        guard let messageID = updateChatLog(atChatID: chatID, message: message)
        else {
            print("No message id found")
            return
        }
        print(messageID)
        message.id = messageID
        
        // For all members of chat, send message to incomingMessages
        do {
            let data = try await FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chats)
                .document(chatID)
                .getDocument(as: Chat.self)
            
            for member in data.userIDArray {
                setIncomingMessage(for: member.key, message: message)
            }
        }
        catch {
            
        }
    }
    
    static private func updateChatLog(atChatID chatID: String, message: Message) -> String? {
        do {
            let docID = try FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chats)
                .document(chatID)
                .collection(FirebaseConstants.chatLogs)
                .addDocument(from: message)
            return docID.documentID
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    static private func setIncomingMessage(for userID: String, message: Message) {
        do {
            guard let messageID = message.id else {return}
            try FirebaseManager.shared.firestore
                .collection(FirebaseConstants.users)
                .document(userID)
                .collection(FirebaseConstants.incomingChats)
                .document(messageID)
                .setData(from: message) {
                    error in
                    print(error?.localizedDescription ?? "")
                }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    static func makeChatObject(fromID chatID: String) async -> Chat? {
        do {
            let document = try await self.shared.firestore
                .collection(FirebaseConstants.chats)
                .document(chatID)
                .getDocument(as: Chat.self)
            
            return document
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func makeFriend(from id: String?, notifications: Bool = true) async -> Friend? {
        guard let id = id else {return nil}
        
        do {
            let data = try await FirebaseManager.shared.firestore
                .collection(FirebaseConstants.users)
                .document(id)
                .getDocument(as: User.self)
            
            guard let friendID = data.id else {return nil}
            let dataAsFriend = Friend(
                email: data.email,
                userID: friendID,
                profilePicURL: data.profilePicURL,
                userName: data.userName,
                notifications: notifications,
                profileOverlayData: data.profileOverlayData
            )
            return dataAsFriend
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
}
