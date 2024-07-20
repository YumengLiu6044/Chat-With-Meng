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
    case confirmPasswordNotMatch = "Confirm password does not match with password"
    case loginCredentialsInvalid = "The email or the password provided is incorrect"
    case accountCreationSuccessful = "Successfully created account"
}

struct LoginView: View {
    var width:  CGFloat
    var height: CGFloat
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        
        // FirebaseApp.configure()
        
        passwordManager.requireLowerCase()
        passwordManager.requireUpperCase()
        passwordManager.requireMinimumSize(of: 10)
        passwordManager.requireSpecialSymbolFromSet(of: "!@#$%^&*()-_=+\\|[]{};:/?.<>~`\"\'")
        
    }
    
    @ObservedObject var passwordManager = PasswordManager()
    
    @State private var toast:               Toast?      =   nil
    @State private var menuOption:          MenuOptions =   .create
    
    @State private var userEmail:           String      =   ""
    @State private var userPassword:        String      =   ""
    @State private var confirmPassword:     String      =   ""
    
    @State private var isLoginSuccess:      Bool        =   false
    @State private var isForgetPassword:    Bool        =   false
    @State private var isRememberMe:        Bool        =   false
    @State private var isPasswordEqual:     Bool        =   true
    
    var body: some View {
        NavigationStack{
            VStack(spacing: height * 0.01) {
                Picker(selection: $menuOption, label: Text("Login")) {
                    ForEach(MenuOptions.allCases, id: \.self) {
                        option in
                        Text(option.rawValue)
                            .font(.subheadline)
                    }
                }
                .pickerStyle(.segmented)
                
                
                Image(systemName: imageDisplayPredicate(isLoginSuccess: isLoginSuccess, menuOption: menuOption))
                    .padding()
                    .font(.system(size: width * 0.2))
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 4)
                            
                            .frame(width: width * 0.4, height: height * 0.4)
                    }
                    .frame(width: width * 0.25, height: height * 0.25)
                
                VStack {
                    TextField("Email", text: $userEmail, prompt: Text("Email").foregroundStyle(.gray))
                        .frame(height: height * 0.03)
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
                    
                    PasswordField(prompt: "Password", width: width, height: height * 0.03,  userPassword: $userPassword)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(.rect(cornerRadius: width * 0.03))
                        .shadow(radius: 3)
                        .onChange(of: menuOption) {
                            userPassword = ""
                        }
                    
                    if menuOption == .create {
                        PasswordField(prompt: "Confirm Password", disableHide: true, width: width, height: height * 0.03, userPassword: $confirmPassword)
                            .padding()
                            .background(.ultraThickMaterial)
                            .clipShape(.rect(cornerRadius: width * 0.03))
                            .shadow(radius: 3)
                            .onDisappear() {
                                confirmPassword = ""
                            }

                        HStack{
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Password must contain:")
                                ForEach(passwordManager.policies) {
                                    policy in
                                    Text("•\(policy.message)")
                                        .font(.caption)
                                        .foregroundStyle(policy.passed ? Color.primary : .red)
                                        .animation(.easeInOut, value: policy.passed)
                                    
                                }
                            }
                            .scaledToFit()
                            .minimumScaleFactor(0.5)
                            Spacer()
                        }
                        .padding()
                        
                            
                    }
                }
                .foregroundStyle(.foreground)
                
                if menuOption == .login {
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
            .font(.title3)
            .navigationTitle(menuOption.rawValue)
            .contentTransition(.symbolEffect(.replace))
            .padding()
            .background(Color(.init(white: 0, alpha: 0.1))
                .ignoresSafeArea())
            .sheet(isPresented: $isForgetPassword) {
                PasswordResetView(isForgetPassword: $isForgetPassword)
            }
            .ignoresSafeArea(.keyboard)
            .toastView(toast: $toast)
            
        }
        
    }
    
    private func imageDisplayPredicate(isLoginSuccess: Bool, menuOption: MenuOptions) -> String {
        return menuOption == .login ? (isLoginSuccess ? "lock.open.fill" : "lock.fill" ) : "person.fill"
    }
    
    private func handleLogin() {
        
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
        
        toast = Toast(style: .success, message: LoginMessages.accountCreationSuccessful.rawValue)
        
        
    }
}


#Preview {
    GeometryReader{ geometry in
        LoginView(width: geometry.size.width, height: geometry.size.height)
            .preferredColorScheme(.light)
    }
}
