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
    
    static public func uploadProfilePic(profilePic: UIImage, completion: @escaping (URL?, [CGFloat]?) -> Void) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid + "/profilePic/")
        guard let imageData = profilePic.jpegData(compressionQuality: 0.1)
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
                    return completion(imgURL, profilePic.averageColor)
                }
            }
        }
    }
}
