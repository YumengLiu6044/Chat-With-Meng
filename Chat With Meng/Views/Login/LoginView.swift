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

struct LoginView: View {
    var width: CGFloat
    var height: CGFloat
    @ObservedObject var passwordManager = PasswordManager()
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        
        // FirebaseApp.configure()
        
        passwordManager.requireLowerCase()
        passwordManager.requireUpperCase()
        passwordManager.requireMinimumSize(of: 10)
        passwordManager.requireSpecialSymbolFromSet(of: "!@#$%^&*()-_=+\\|[]{};:/?.<>~`\"\'")
        
    }
    
    @State private var menuOption:          MenuOptions =   .create
    
    @State private var userEmail:           String      =   ""
    @State private var userPassword:        String      =   ""
    @State private var confirmPassword:     String      =   ""
    
    @State private var isLoginSuccess:      Bool        =   false
    @State private var isForgetPassword:    Bool        =   false
    @State private var rememberMe:          Bool        =   false
    
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
                    .font(.system(size: width * 0.25))
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 4)
                            
                            .frame(width: width * 0.43, height: height * 0.43)
                    }
                    .frame(width: width * 0.3, height: height * 0.3)
                
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
                    
                    PasswordField(prompt: "Password", width: width, height: height * 0.03,  userPassword: $userPassword)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(.rect(cornerRadius: width * 0.03))
                        .shadow(radius: 3)
                    
                    if menuOption == .create {
                        PasswordField(prompt: "Confirm Password", disableHide: true, width: width, height: height * 0.03, userPassword: $confirmPassword)
                            .padding()
                            .background(.ultraThickMaterial)
                            .clipShape(.rect(cornerRadius: width * 0.03))
                            .shadow(radius: 3)
                        
                        HStack{
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Password must contain:")
                                ForEach(passwordManager.policies) {
                                    policy in
                                    Text("•\(policy.message)")
                                        .font(.caption)
                                    
                                }
                            }
                            
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
                            rememberMe.toggle()
                        } label: {
                            Text("Remember me")
                            Image(systemName: rememberMe ? "checkmark.square" : "square")
                                
                        }
                        
                    }
                    .font(.subheadline)
                    .foregroundStyle(.foreground)
                    .padding()
                }
                
                Spacer()
                Button {
                    isLoginSuccess.toggle()
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
            
        }
        
    }
    
    private func imageDisplayPredicate(isLoginSuccess: Bool, menuOption: MenuOptions) -> String {
        return menuOption == .login ? (isLoginSuccess ? "lock.open.fill" : "lock.fill" ) : "person.fill"
    }
    
    private func handleLogin() {
        
    }
    
    private func handleAccountCreation() {
        
    }
}


#Preview {
    GeometryReader{ geometry in
        LoginView(width: geometry.size.width, height: geometry.size.height)
            .preferredColorScheme(.dark)
    }
}
