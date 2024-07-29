import Firebase

class FirebaseManager: NSObject {
    
    let auth: Auth
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        auth = Auth.auth()
        super.init()
    }
}
