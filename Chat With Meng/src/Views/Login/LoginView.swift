//
//  ContentView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/11/24.
//

import Firebase
import SwiftUI


struct LoginView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject var loginViewModel = LoginViewModel()
    
    @FocusState private var focus: FocusField?
    
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    @ViewBuilder
    func createButton() -> some View {
        Button {
            if loginViewModel.menuOption == .login {
                loginViewModel.handleLogin() {
                    loginResult in
                    
                    if (loginResult == true) {
                        if (loginViewModel.isRememberMe) {
                            appViewModel.saveLoginInfo(loginViewModel.userEmail, loginViewModel.userPassword)
                        }
                        else {
                            appViewModel.clearSavedLoginInfo()
                        }
                        appViewModel.switchTo(view: .chat)
                    }
                }
                
            } else {
                loginViewModel.handleAccountCreation() {
                    result in
                    if (loginViewModel.isRememberMe) {
                        appViewModel.saveLoginInfo(loginViewModel.userEmail, loginViewModel.userPassword)
                    }
                    else {
                        appViewModel.clearSavedLoginInfo()
                    }
                    appViewModel.switchTo(view: .chat)
                }
                
            }
        } label: {
            HStack {
                Spacer()
                if loginViewModel.isLoading {
                    ProgressView()
                }
                else {
                    Text(
                        loginViewModel.menuOption == .login
                        ? "Login" : "Register Account"
                    )
                    .font(.title2)
                    .animation(.easeIn, value: loginViewModel.menuOption)
                }
                
                Spacer()
                
                
            }
            
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: width * 0.03))
    }
    
    @ViewBuilder
    func createTopPicture() -> some View {
        if loginViewModel.menuOption == .login {
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
        else if loginViewModel.menuOption == .create {
            Button {
                loginViewModel.isShowImagePicker.toggle()
            } label: {
                if let profilePic = loginViewModel.profilePic {
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
    }
    
    @ViewBuilder
    func createFields() -> some View {
        VStack {
            TextField(
                "Email", text: $loginViewModel.userEmail,
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
            .onChange(of: loginViewModel.menuOption) {
                loginViewModel.userEmail = ""
            }
            .overlay {
                RoundedRectangle(cornerRadius: width * 0.03)
                    .stroke(.blue.opacity(0.8), lineWidth: (focus == .email) ? 2 : 0)
            }
            .focused($focus, equals: .email)
            .onDisappear {
                focus = nil
            }
            
            if loginViewModel.menuOption == .login {
                PasswordField(
                    prompt: "Password", width: width,
                    height: height * 0.02,
                    userPassword: $loginViewModel.userPassword
                )
                .padding()
                .background(.ultraThickMaterial)
                .clipShape(.rect(cornerRadius: width * 0.03))
                .shadow(radius: 3)
                .overlay {
                    RoundedRectangle(cornerRadius: width * 0.03)
                        .stroke(.blue.opacity(0.8), lineWidth: (focus == .password) ? 2 : 0)
                }
                .focused($focus, equals: .password)
                .onDisappear {
                    focus = nil
                }
                
                HStack {
                    Button {
                        loginViewModel.isForgetPassword = true
                    } label: {
                        Text("Forgot Password")
                        
                    }
                    Spacer()
                    Button {
                        loginViewModel.isRememberMe.toggle()
                    } label: {
                        Text("Remember me")
                        Image(
                            systemName: loginViewModel.isRememberMe
                            ? "checkmark.square" : "square")
                        
                    }
                    
                }
                .font(.subheadline)
                .foregroundStyle(.foreground)
                .padding()
                
            }
            if loginViewModel.menuOption == .create {
                PasswordField(
                    prompt: "Password", width: width,
                    height: height * 0.02,
                    userPassword: $loginViewModel.userPassword
                )
                .padding()
                .background(.ultraThickMaterial)
                
                .clipShape(.rect(cornerRadius: width * 0.03))
                .shadow(radius: 3)
                .overlay {
                    RoundedRectangle(cornerRadius: width * 0.03)
                        .stroke(.blue.opacity(0.8), lineWidth: (focus == .password) ? 2 : 0)
                }
                .focused($focus, equals: .password)
                .onChange(of: loginViewModel.userPassword) {
                    let _ = loginViewModel.passwordManager.passwordIsValid(
                        for: loginViewModel.userPassword)
                }
                .onDisappear {
                    focus = nil
                }
                
                PasswordField(
                    prompt: "Confirm Password", disableHide: true,
                    width: width, height: height * 0.02,
                    userPassword: $loginViewModel.confirmPassword
                )
                .padding()
                .focused($focus, equals: .confirmPassword)
                .background(.ultraThickMaterial)
                .clipShape(.rect(cornerRadius: width * 0.03))
                .overlay {
                    RoundedRectangle(cornerRadius: width * 0.03)
                        .stroke(.blue.opacity(0.8), lineWidth: (focus == .confirmPassword) ? 2 : 0)
                }
                .shadow(radius: 3)
                .onDisappear {
                    loginViewModel.confirmPassword = ""
                    focus = nil
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Password must contain:")
                        ForEach(loginViewModel.passwordManager.policies) {
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
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text(loginViewModel.menuOption.rawValue)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
                }
                Picker(selection: $loginViewModel.menuOption, label: Text("Login")) {
                    ForEach(MenuOptions.allCases, id: \.self) {
                        option in
                        Text(option.rawValue)
                            .font(.subheadline)
                    }
                }
                .onChange(
                    of: loginViewModel.menuOption,
                    {
                        loginViewModel.userPassword = ""
                    }
                )
                .pickerStyle(.segmented)
                
                createTopPicture()
                
                createFields()
                
                Spacer()
                createButton()
                
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
            .sheet(isPresented: $loginViewModel.isForgetPassword) {
                PasswordResetView(
                    isForgetPassword: $loginViewModel.isForgetPassword, width: width,
                    height: height)
            }
            .fullScreenCover(isPresented: $loginViewModel.isShowImagePicker, onDismiss: nil)
            {
                ImagePicker(image: $loginViewModel.profilePic)
            }
            .toastView(toast: $loginViewModel.toast)
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
                (loginViewModel.userEmail, loginViewModel.userPassword) = appViewModel.retrieveLoginInfo()
                if (!loginViewModel.userEmail.isEmpty && !loginViewModel.userPassword.isEmpty) {
                    loginViewModel.handleLogin {
                        loginResult in
                        if (loginResult == true) {
                            appViewModel.switchTo(view: .chat)
                        }
                    }
                    
                }
                
            }
        }
    }
    
}

#Preview {
    LoginView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
    
}
