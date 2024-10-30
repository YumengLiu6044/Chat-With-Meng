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
    
    static func makeGroupChat(with name: String, of members: [Friend], completion: @escaping (Toast) -> Void) {
        if (name.isEmpty) {
            let toast = Toast(style: .error, message: "Name is empty")
            return completion(toast)
        }
        if (name.allSatisfy {$0.isWhitespace}) {
            let toast = Toast(style: .error, message: "At least one non-space character is required")
            return completion(toast)
        }
        if (!name.allSatisfy {$0.isLetter || $0.isNumber || $0.isWhitespace}) {
            let toast = Toast(style: .error, message: "Only alpha-numeric characters and spaces are allowed")
            return completion(toast)
        }
        if (name.count > 30) {
            let toast = Toast(style: .error, message: "The maximum character count is 30")
            return completion(toast)
        }
        
        uploadChatDataToFirestore(
            members: members,
            name: name,
            completion: completion
        )
    }
    
    static private func uploadChatDataToFirestore(members: [Friend], name: String, completion: @escaping (Toast) -> Void) {
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
                        let toast = Toast(style: .error, message: error.localizedDescription)
                        return completion(toast)
                    }
                    else {
                        let toast = Toast(style: .success, message: "You have made the \"\(name)\"")
                        return completion(toast)
                    }
                }
            
        }
        catch {
            let toast = Toast(style: .error, message: "Failed to make new chat")
            return completion(toast)
        }
    }
    
    static func sendMessage(from senderID: String, to chatID: String, of content: Message) {
        
    }
}
