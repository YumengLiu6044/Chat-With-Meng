//
//  ContentView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/11/24.
//

import SwiftUI
import Firebase

enum MenuOptions: String, CaseIterable {
    case login = "Login"
    case create = "Create Account"
}

enum LoginMessages: String {
    case createPasswordInvalid = "Invalid password"
    case createUserError = "User creation failed"
    case createUserSuccessful = "Successfully created account"
    case confirmPasswordNotMatch = "Confirm password does not match with password"
    case loginCredentialsInvalid = "The email or the password provided is incorrect"
    case loginSuccessful = "Successfully logged in"
}

enum FocusField: Hashable {
    case email, password, confirmPassword
}

struct LoginView: View {
    init() {
        passwordManager.requireLowerCase()
        passwordManager.requireUpperCase()
        passwordManager.requireMinimumSize(of: 10)
        passwordManager.requireSpecialSymbolFromSet(of: "!@#$%^&*()-_=+\\|[]{};:/?.<>~`\"\'")
    }
    
    @ObservedObject var passwordManager = PasswordManager()
    
    @State private var toast:               Toast?      =   nil
    @State private var menuOption:          MenuOptions =   .create
    @FocusState private var focus:          FocusField?
    @State private var profilePic:          UIImage?    =   nil
    
    @State private var width:               CGFloat     =   100
    @State private var height:              CGFloat     =   100
    
    @State private var userEmail:           String      =   ""
    @State private var userPassword:        String      =   ""
    @State private var confirmPassword:     String      =   ""
    
    @State private var isLoginSuccess:      Bool        =   false
    @State private var isForgetPassword:    Bool        =   false
    @State private var isRememberMe:        Bool        =   false
    @State private var isPasswordEqual:     Bool        =   true
    @State private var showImagePicker:     Bool        =   false
    
    var body: some View {
        GeometryReader {geometry in
            NavigationStack{
                VStack {
                    Picker(selection: $menuOption, label: Text("Login")) {
                        ForEach(MenuOptions.allCases, id: \.self) {
                            option in
                            Text(option.rawValue)
                                .font(.subheadline)
                        }
                    }
                    .onChange(of: menuOption, {
                        userPassword = ""
                    })
                    .pickerStyle(.segmented)
                    
                    
                    if menuOption == .login {
                        Image(systemName: isLoginSuccess ? "lock.open.fill" : "lock.fill")
                            .padding()
                            .font(.system(size: width * 0.2))
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 4)
                                
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
                                    .frame(width: width * 0.4, height: width * 0.4)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .stroke(lineWidth: 4)
                                    }
                                    .tint(Color.primary)
                                    .padding()
                                
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: width * 0.2))
                                    .overlay {
                                        Circle()
                                            .stroke(lineWidth: 4)
                                        
                                            .frame(width: width * 0.4, height: height * 0.4)
                                    }
                                    .frame(width: width * 0.25, height: height * 0.25)
                                    .tint(Color.primary)
                            }
                        }
                        
                    }
                    
                    VStack {
                        TextField("Email", text: $userEmail, prompt: Text("Email").foregroundStyle(.gray))
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
                            PasswordField(prompt: "Password", width: width, height: height * 0.02,  userPassword: $userPassword)
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
                                    Image(systemName: isRememberMe ? "checkmark.square" : "square")
                                    
                                }
                                
                            }
                            .font(.subheadline)
                            .foregroundStyle(.foreground)
                            .padding()
                                
                        }
                        if menuOption == .create {
                            PasswordField(prompt: "Password", width: width, height: height * 0.02,  userPassword: $userPassword)
                                .padding()
                                .background(.ultraThickMaterial)
                                .clipShape(.rect(cornerRadius: width * 0.03))
                                .shadow(radius: 3)
                                .focused($focus, equals: .password)
                                .onChange(of: userPassword) {
                                    let _ = passwordManager.passwordIsValid(for: userPassword)
                                }
                                .onDisappear {
                                    focus = nil
                                }
                                
                            
                            PasswordField(prompt: "Confirm Password", disableHide: true, width: width, height: height * 0.02, userPassword: $confirmPassword)
                                .padding()
                                .focused($focus, equals: .confirmPassword)
                                .background(.ultraThickMaterial)
                                .clipShape(.rect(cornerRadius: width * 0.03))
                                .shadow(radius: 3)
                                .onDisappear() {
                                    confirmPassword = ""
                                    focus = nil
                                }
                            
                            HStack{
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Password must contain:")
                                    ForEach(passwordManager.policies) {
                                        policy in
                                        Text("•  \(policy.message)")
                                            .font(.body)
                                            .foregroundStyle(policy.passed ? Color.primary : .red)
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
                        }
                        else {
                            handleAccountCreation()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text(menuOption == .login ? "Login" : "Register Account")
                                .font(.title2)
                                .animation(.easeIn, value: menuOption)
                            Spacer()
                        }
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: width * 0.03))
                    
                    Spacer()
                }
                .ignoresSafeArea(.keyboard)
                .font(.title3)
                .navigationTitle(menuOption.rawValue)
                .contentTransition(.symbolEffect(.replace))
                .padding()
                .background(Color(.init(white: 0, alpha: 0.1))
                    .ignoresSafeArea())
                .sheet(isPresented: $isForgetPassword) {
                    PasswordResetView(isForgetPassword: $isForgetPassword, width: width, height: height)
                }
                .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                    ImagePicker(image: $profilePic)
                }
                .toastView(toast: $toast)
                
            }
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
            }
        }
    }
    
    private func handleLogin() {
        if userEmail.isEmpty || userPassword.isEmpty {
            toast = Toast(style: .error, message: LoginMessages.loginCredentialsInvalid.rawValue)
            return
        }
        
        FirebaseManager.shared.auth.signIn(withEmail: userEmail, password: userPassword) { result, err in
            if let err = err {
                toast = Toast(style: .error, message: err.localizedDescription)
                isLoginSuccess = false
                return
            }
            if let result = result {
                toast = Toast(style: .success, message: LoginMessages.loginSuccessful.rawValue)
                print(result.user.uid)
                isLoginSuccess = true
            }
            else  {
                toast = Toast(style: .error, message: LoginMessages.loginCredentialsInvalid.rawValue)
                isLoginSuccess = false
            }
        }
    }
    
    private func handleAccountCreation() {
        if !passwordManager.passwordIsValid(for: userPassword) {
            toast = Toast(style: .error, message: LoginMessages.createPasswordInvalid.rawValue)
            return
        }
        if userPassword != confirmPassword {
            toast = Toast(style: .error, message: LoginMessages.confirmPasswordNotMatch.rawValue)
            return
        }
        
        if userEmail.isEmpty {
            toast = Toast(style: .error, message: LoginMessages.createUserError.rawValue)
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: userEmail, password: userPassword) { result, err in
            if let err = err {
                print(err.localizedDescription)
                toast = Toast(style: .error, message: err.localizedDescription)
                return
            }
            
            if let _ = result {
                toast = Toast(style: .success, message: LoginMessages.createUserSuccessful.rawValue)
            }
            else {
                toast = Toast(style: .error, message: LoginMessages.createUserError.rawValue)
            }
            
            
        }
        
        
        
        
        
    }
}


#Preview {
    LoginView()
        .preferredColorScheme(.dark)
    
}
