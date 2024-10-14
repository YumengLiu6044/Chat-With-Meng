//
//  LoginViewModel.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/14/24.
//

import Foundation
import SwiftUI

enum LoginMessages: String {
    case createPasswordInvalid = "Invalid password"
    case createUserError = "User creation failed"
    case createUserSuccessful = "Successfully created account"
    case confirmPasswordNotMatch =
        "Confirm password does not match with password"
    case loginCredentialsInvalid =
        "The email or the password provided is incorrect"
    case loginSuccessful = "Successfully logged in"
    case uploadUserDataSuccessful = "Successfully uploaded user data"
    case uploadUserDataFailed = "Failed to upload user data"
}

enum MenuOptions: String, CaseIterable {
    case login = "Login"
    case create = "Create Account"
}


class LoginViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var userPassword: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var toast: Toast?
    @Published var profilePic: UIImage?
    @Published var menuOption: MenuOptions = .login
    
    @Published var isLoading: Bool = false
    @Published var isRememberMe: Bool = true
    @Published var isForgetPassword: Bool = false
    @Published var isShowImagePicker: Bool = false
    
    private var passwordManager: PasswordManager = PasswordManager()
    
    
    
    public func handleLogin(completion: @escaping (Bool) -> Void) {
        if userEmail.isEmpty || userPassword.isEmpty {
            toast = Toast(
                style: .error,
                message: LoginMessages.loginCredentialsInvalid.rawValue)
            completion(false)
            return
        }
        
        isLoading = true
        
        FirebaseManager.shared.auth.signIn(
            withEmail: self.userEmail, password: self.userPassword
        ) { result, err in
            if let err = err {
                self.toast = Toast(style: .error, message: err.localizedDescription)
                self.isLoading = false
                completion(false)
            }
            if let _ = result {
                self.toast = Toast(style: .success, message: LoginMessages.loginSuccessful.rawValue)
                self.isLoading = false
                completion(true)
            }
            else  {
                self.toast = Toast(style: .error, message: LoginMessages.loginCredentialsInvalid.rawValue)
                self.isLoading = false
                completion(true)
            }
        }
    }
    
    public func handleAccountCreation() {
        if !passwordManager.passwordIsValid(for: userPassword) {
            toast = Toast(
                style: .error,
                message: LoginMessages.createPasswordInvalid.rawValue)
            return
        }
        if userPassword != confirmPassword {
            toast = Toast(
                style: .error,
                message: LoginMessages.confirmPasswordNotMatch.rawValue)
            return
        }

        if userEmail.isEmpty {
            toast = Toast(
                style: .error, message: LoginMessages.createUserError.rawValue)
            return
        }

        guard profilePic != nil else {
            toast = Toast(style: .error, message: "Please upload a profile pic")
            return
        }
        
        isLoading = true
        
        FirebaseManager.shared.auth.createUser (
            withEmail: userEmail, password: userPassword
        ) { result, err in
            if let err = err {
                print(err.localizedDescription)
                self.toast = Toast(style: .error, message: err.localizedDescription)
                self.isLoading = false
                return
            } else {
                self.uploadUserData()
                self.toast = Toast(style: .success, message: LoginMessages.createUserSuccessful.rawValue)
                self.menuOption = .login
            }
        }
        return
    }

    private func uploadProfilePic() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = profilePic?.jpegData(compressionQuality: 0.5)
        else { return }

        ref.putData(imageData) {
            metadata, error in

            if let error = error {
                self.toast = Toast(
                    style: .error, message: error.localizedDescription)
                print(error.localizedDescription)
                self.isLoading = false
                return
            }
            
            ref.downloadURL {
                imgURL, err in
                if let error = err {
                    self.toast = Toast(
                        style: .error, message: error.localizedDescription)
                    self.isLoading = false
                }
                if let imgURL = imgURL {
                    self.uploadToCloud(profilePicURL: imgURL)
                    
                } else {
                    self.toast = Toast(
                        style: .error,
                        message:
                            "Unknown error encountered when uploading profile Picture"
                    )
                    self.isLoading = false
                }
            }
        }
        
    }
    
    private func uploadUserData() {
        return uploadProfilePic()
    }
    
    private func uploadToCloud(profilePicURL: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let emailOnFile = FirebaseManager.shared.auth.currentUser?.email else {return}
        let userData = [
            "email": emailOnFile,
            "uid": uid,
            "profilePic": profilePicURL.absoluteString,
        ]
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData) {
            error in
            if let error = error {
                self.toast = Toast(
                    style: .error, message: error.localizedDescription)
                print(error.localizedDescription)
                self.isLoading = false
                return
            }
            else {
                self.isLoading = false
            }
        }
    }
}
