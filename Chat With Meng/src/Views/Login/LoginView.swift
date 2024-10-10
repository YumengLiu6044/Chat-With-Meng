//
//  ContentView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/11/24.
//

import Firebase
import SwiftUI

enum MenuOptions: String, CaseIterable {
    case login = "Login"
    case create = "Create Account"
}

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

enum FocusField: Hashable {
    case email, password, confirmPassword
}

struct LoginView: View {
    init() {
        passwordManager.requireLowerCase()
        passwordManager.requireUpperCase()
        passwordManager.requireMinimumSize(of: 10)
        passwordManager.requireSpecialSymbolFromSet(
            of: "!@#$%^&*()-_=+\\|[]{};:/?.<>~`\"\'")
        
    }

    @EnvironmentObject private var appViewModel: AppViewModel

    @ObservedObject var passwordManager = PasswordManager()

    @State private var toast: Toast? = nil
    @State private var menuOption: MenuOptions = .login
    @FocusState private var focus: FocusField?
    @State private var profilePic: UIImage? = nil
    
    @AppStorage("saved_email") private var savedEmail: String = ""
    @AppStorage("saved_password") private var savedPassword: String = ""
    @AppStorage("saved_profil_pic_url") private var savedProfilePicURL: String = ""

    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    @State private var userEmail: String = ""
    @State private var userPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var isForgetPassword: Bool = false
    @State private var isRememberMe: Bool = false
    @State private var isPasswordEqual: Bool = true
    @State private var showImagePicker: Bool = false
    @State private var isLoading:       Bool = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text(menuOption.rawValue)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
                }
                    Picker(selection: $menuOption, label: Text("Login")) {
                        ForEach(MenuOptions.allCases, id: \.self) {
                            option in
                            Text(option.rawValue)
                                .font(.subheadline)
                        }
                    }
                    .onChange(
                        of: menuOption,
                        {
                            userPassword = ""
                        }
                    )
                    .pickerStyle(.segmented)

                    if menuOption == .login {
                        Image(systemName: "person.fill")
                            .padding()
                            .font(.system(size: width * 0.2))
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 5)
                                    .frame(width: width * 0.4, height: height * 0.4)
                            }
                            .frame(width: width * 0.25, height: height * 0.25)
                    }
                    else if menuOption == .create {
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            if let profilePic = profilePic {
                                Image(uiImage: profilePic)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: width * 0.4, height: width * 0.4
                                    )
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .stroke(lineWidth: 5)
                                    }
                                    .tint(Color.primary)
                                    .padding()

                            } else {
                                Image(systemName: "person.badge.plus")
                                        .font(.system(size: width * 0.2))
                                        .overlay {
                                            Circle()
                                                .stroke(lineWidth: 5)

                                                .frame(
                                                    width: width * 0.4,
                                                    height: height * 0.4)
                                        }
                                        .frame(
                                            width: width * 0.25,
                                            height: height * 0.25
                                        )
                                        .tint(Color.primary)
                                
                            }
                        }

                    }

                    VStack {
                        TextField(
                            "Email", text: $userEmail,
                            prompt: Text("Email").foregroundStyle(.gray)
                        )
                        .frame(height: height * 0.02)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(.rect(cornerRadius: width * 0.03))
                        .shadow(radius: 3)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .onChange(of: menuOption) {
                            userEmail = ""
                        }
                        .focused($focus, equals: .email)
                        .onDisappear {
                            focus = nil
                        }

                        if menuOption == .login {
                            PasswordField(
                                prompt: "Password", width: width,
                                height: height * 0.02,
                                userPassword: $userPassword
                            )
                            .padding()
                            .background(.ultraThickMaterial)
                            .clipShape(.rect(cornerRadius: width * 0.03))
                            .shadow(radius: 3)
                            .focused($focus, equals: .password)
                            .onDisappear {
                                focus = nil
                            }

                            HStack {
                                Button {
                                    isForgetPassword = true
                                } label: {
                                    Text("Forgot Password")

                                }
                                Spacer()
                                Button {
                                    isRememberMe.toggle()
                                } label: {
                                    Text("Remember me")
                                    Image(
                                        systemName: isRememberMe
                                            ? "checkmark.square" : "square")

                                }

                            }
                            .font(.subheadline)
                            .foregroundStyle(.foreground)
                            .padding()

                        }
                        if menuOption == .create {
                            PasswordField(
                                prompt: "Password", width: width,
                                height: height * 0.02,
                                userPassword: $userPassword
                            )
                            .padding()
                            .background(.ultraThickMaterial)

                            .clipShape(.rect(cornerRadius: width * 0.03))
                            .shadow(radius: 3)
                            .focused($focus, equals: .password)
                            .onChange(of: userPassword) {
                                let _ = passwordManager.passwordIsValid(
                                    for: userPassword)
                            }
                            .onDisappear {
                                focus = nil
                            }

                            PasswordField(
                                prompt: "Confirm Password", disableHide: true,
                                width: width, height: height * 0.02,
                                userPassword: $confirmPassword
                            )
                            .padding()
                            .focused($focus, equals: .confirmPassword)
                            .background(.ultraThickMaterial)
                            .clipShape(.rect(cornerRadius: width * 0.03))
                            .shadow(radius: 3)
                            .onDisappear {
                                confirmPassword = ""
                                focus = nil
                            }

                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Password must contain:")
                                    ForEach(passwordManager.policies) {
                                        policy in
                                        Text("•  \(policy.message)")
                                            .font(.body)
                                            .foregroundStyle(
                                                policy.passed
                                                    ? Color.primary : .red)
                                    }
                                }
                                .scaledToFit()
                                .minimumScaleFactor(0.5)
                                Spacer()
                            }
                            .padding()

                        }
                    }

                    Spacer()
                    Button {
                        if menuOption == .login {
                            handleLogin()
                        } else {
                            handleAccountCreation()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            }
                            else {
                                Text(
                                    menuOption == .login
                                        ? "Login" : "Register Account"
                                )
                                .font(.title2)
                                .animation(.easeIn, value: menuOption)
                            }
                            
                            Spacer()
                            
                            
                        }

                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: width * 0.03))

                    Spacer()
                }
                .ignoresSafeArea(.keyboard)
                .font(.title3)
                .contentTransition(.symbolEffect(.replace))
                .padding()
                .background(
                    Color(.init(white: 0, alpha: 0.1))
                        .ignoresSafeArea()
                )
                .sheet(isPresented: $isForgetPassword) {
                    PasswordResetView(
                        isForgetPassword: $isForgetPassword, width: width,
                        height: height)
                }
                .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil)
                {
                    ImagePicker(image: $profilePic)
                }
                .toastView(toast: $toast)
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                    retrieveLoginInfo()
                    
                }
        }
    }

    private func handleLogin() {
        if userEmail.isEmpty || userPassword.isEmpty {
            toast = Toast(
                style: .error,
                message: LoginMessages.loginCredentialsInvalid.rawValue)
            return
        }
        
        isLoading = true
        FirebaseManager.shared.auth.signIn(
            withEmail: userEmail, password: userPassword
        ) { result, err in
            if let err = err {
                toast = Toast(style: .error, message: err.localizedDescription)
                return
            }
            if let _ = result {
                toast = Toast(style: .success, message: LoginMessages.loginSuccessful.rawValue)
                
                if isRememberMe {
                    saveLoginInfo()
                }
                else {
                    clearSavedLoginInfo()
                }
                isLoading = false
                appViewModel.switchTo(view: .chat, animationLength: 1)
            }
            else  {
                toast = Toast(style: .error, message: LoginMessages.loginCredentialsInvalid.rawValue)
                
            }
        }
    }
    
    private func saveLoginInfo() {
        savedEmail = userEmail
        savedPassword = userPassword
    }
    
    private func clearSavedLoginInfo() {
        savedEmail = ""
        savedPassword = ""
    }
    
    private func retrieveLoginInfo() {
        userEmail = savedEmail
        userPassword = savedPassword
        
    }
    
    private func handleAccountCreation() {
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
                toast = Toast(style: .error, message: err.localizedDescription)
                return
            } else {
                uploadUserData()
                toast = Toast(style: .success, message: LoginMessages.createUserSuccessful.rawValue)
                menuOption = .login
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
                toast = Toast(
                    style: .error, message: error.localizedDescription)
                print(error.localizedDescription)
            }
            
            ref.downloadURL {
                imgURL, err in
                if let error = err {
                    toast = Toast(
                        style: .error, message: error.localizedDescription)
                }
                if let imgURL = imgURL {
                    uploadToCloud(profilePicURL: imgURL)
                    
                } else {
                    toast = Toast(
                        style: .error,
                        message:
                            "Unknown error encountered when uploading profile Picture"
                    )
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
                
                toast = Toast(
                    style: .error, message: error.localizedDescription)
                print(error.localizedDescription)
                return
            }
            else {
                isLoading = false
            }
        }
    }

}

#Preview {
    LoginView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)

}
