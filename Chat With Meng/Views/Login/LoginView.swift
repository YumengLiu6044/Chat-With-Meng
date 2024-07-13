//
//  ContentView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/11/24.
//

import SwiftUI

enum MenuOptions: String, CaseIterable {
    case login = "Login"
    case create = "Create Account"
}

struct LoginView: View {
    var width: CGFloat
    var height: CGFloat
    
    @State private var menuOption: MenuOptions  =   .login
    @State private var userEmail: String        =   ""
    @State private var userPassword: String     =   ""
    @State private var confirmPassword: String  =   ""
    @State private var isLoginSuccess: Bool     =   false
    @State private var rememberMe = false
    
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
                    .font(.system(size: width * 0.3))
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 4)
                            .shadow(radius: 3)
                            .frame(width: width * 0.4, height: height * 0.4)
                    }
                    .frame(width: width * 0.3, height: height * 0.3)
                    
                    
                    
                
                VStack {
                    TextField("Email", text: $userEmail, prompt: Text("Email").foregroundStyle(.gray))
                        .frame(height: height * 0.03)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: width * 0.03))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                    
                    PasswordView(prompt: "Password", width: width, height: height * 0.03,  userPassword: $userPassword)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: width * 0.03))
                    
                    if menuOption == .create {
                        PasswordView(prompt: "Confirm Password", disableHide: true, width: width, height: height * 0.03, userPassword: $confirmPassword)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: width * 0.03))
                            
                    }
                }
                .foregroundStyle(.foreground)
                
                if menuOption == .login {
                    HStack {
                        Spacer()
                        Button {
                            rememberMe.toggle()
                        } label: {
                            Text("Remember me")
                            Image(systemName: rememberMe ? "checkmark.square" : "square")
                                
                        }
                        .foregroundStyle(.foreground)
                    }
                    .padding()
                }
                
                Spacer()
                Button {
                    
                } label: {
                    HStack {
                        Spacer()
                        Text(menuOption == .login ? "Login" : "Register Account")
                            .animation(.easeIn, value: menuOption)
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: width * 0.02))
                
                Spacer()
            }
            .font(.title3)
            .navigationTitle(menuOption.rawValue)
            .contentTransition(.symbolEffect(.replace))
            .padding()
            .background(Color(.init(white: 0, alpha: 0.1))
                .ignoresSafeArea())
        }
        
    }
    
    private func imageDisplayPredicate(isLoginSuccess: Bool, menuOption: MenuOptions) -> String {
        return menuOption == .login ? (isLoginSuccess ? "lock.open.fill" : "lock.fill" ) : "person.fill"
    }
}


#Preview {
    GeometryReader{ geometry in
        LoginView(width: geometry.size.width, height: geometry.size.height)
            .preferredColorScheme(.dark)
    }
}
