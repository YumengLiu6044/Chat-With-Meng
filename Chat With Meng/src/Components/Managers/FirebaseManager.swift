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
    
    static func makeGroupChat(with name: String, of members: [Friend], completion: @escaping (Toast, Chat?) -> Void) {
        if (name.isEmpty) {
            let toast = Toast(style: .error, message: "Name is empty")
            return completion(toast, nil)
        }
        if (name.allSatisfy {$0.isWhitespace}) {
            let toast = Toast(style: .error, message: "At least one non-space character is required")
            return completion(toast, nil)
        }
        if (!name.allSatisfy {$0.isLetter || $0.isNumber || $0.isWhitespace}) {
            let toast = Toast(style: .error, message: "Only alpha-numeric characters and spaces are allowed")
            return completion(toast, nil)
        }
        if (name.count > 30) {
            let toast = Toast(style: .error, message: "The maximum character count is 30")
            return completion(toast, nil)
        }
        let chat = Chat (
            chatID: nil,
            userIDArray: Dictionary(uniqueKeysWithValues: members.map { ($0.userID, "") }),
            chatTitle: name
        )
        
        uploadChatDataToFirestore(
            chat: chat
        ) {
            docID in
            if let docID = docID {
                let toast = Toast(style: .success, message: docID)
                return completion(toast, chat)
            }
            else {
                let toast = Toast(style: .error, message: "Failed to upload chat data")
                return completion(toast, nil)
            }
        }
    }
    
    static private func uploadChatDataToFirestore(chat: Chat, completion: @escaping (String?) -> Void) {
        do {
            let docRef = try FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chats)
                .addDocument(from: chat)
            return completion(docRef.documentID)
            
        }
        catch {
            return completion(nil)
        }
    }
    
    static func sendMessage(
        fromSender senderID: String,
        toChat chatID: String,
        contentType: ContentType,
        content: String,
        time: Date
    ){
        let message = Message(
            contentType: contentType,
            content: content,
            chatID: chatID,
            fromUserID: senderID
        )
        
        // Add message to chatLogs at chatID
        updateChatLog(atChatID: chatID, message: message)
        
        // For all members of chat, send message to incomingMessages
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chats)
            .document(chatID)
            .getDocument {
                document, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let document = document {
                    do {
                        let data = try document.data(as: Chat.self)
                        
                        for member in data.userIDArray {
                            setIncomingMessage(for: member.key, message: message)
                        }
                    }
                    catch {
                        print(error.localizedDescription)
                        return
                    }
                }
                else {
                    print("No document found")
                }
                
            }
    }
    
    static private func updateChatLog(atChatID chatID: String, message: Message) {
        do {
            try FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chats)
                .document(chatID)
                .collection(FirebaseConstants.chatLogs)
                .addDocument(from: message) {
                    error in
                    print(error?.localizedDescription ?? "")
                }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    static private func setIncomingMessage(for userID: String, message: Message) {
        do {
            try FirebaseManager.shared.firestore
                .collection(FirebaseConstants.users)
                .document(userID)
                .collection(FirebaseConstants.incomingChats)
                .addDocument(from: message) {
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
    
}
