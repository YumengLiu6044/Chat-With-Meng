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
}
