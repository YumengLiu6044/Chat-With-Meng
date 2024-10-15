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
                completion(false)
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
                self.toast = Toast(style: .error, message: err.localizedDescription)
                self.isLoading = false
                return
            } else {
                self.uploadUserData {
                    success in
                    if (success) {
                        self.toast = Toast(style: .success, message: LoginMessages.createUserSuccessful.rawValue)
                        self.menuOption = .login
                    }
                    self.isLoading = false
                }
            }
        }
        return
    }
    
    private func uploadUserData(completion: @escaping (Bool) -> Void) {
        guard let profilePic = profilePic else {return completion(false)}
        FirebaseManager.uploadProfilePic(profilePic: profilePic) {
            url, colorData in
            if let url = url, let colorData = colorData {
                self.uploadToCloud(profilePicURL: url, colorData: colorData, completion: completion)
            }
            else {
                self.toast = Toast(style: .error, message: "Error uploading profile picture")
                completion(false)
            }
        }
    }
    
    private func uploadToCloud(profilePicURL: URL, colorData: [CGFloat], completion: @escaping (Bool) -> Void) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let emailOnFile = FirebaseManager.shared.auth.currentUser?.email else {return}
        guard let profilePic = profilePic else {return}
        
        var userData = User()
        userData.email = emailOnFile
        userData.userName = String(userData.email[..<emailOnFile.firstIndex(of: "@")!])
        userData.profilePicURL = profilePicURL
        userData.uid = uid
        userData.profileOverlayData = colorData
        
        do {
            try FirebaseManager.shared.firestore.collection("users").document(uid).setData(from: userData) {
                error in
                if let error = error {
                    print(error.localizedDescription)
                    return completion(false)
                }
                else {
                    return completion(true)
                }
            }
        } catch {
            return completion(false)
        }
    }
}
