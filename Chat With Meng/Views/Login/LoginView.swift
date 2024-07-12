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
    
    var body: some View {
        NavigationStack{
            VStack(spacing: height * 0.01) {
                Picker(selection: $menuOption, label: Text("Login")) {
                    ForEach(MenuOptions.allCases, id: \.self) {
                        option in
                        Text(option.rawValue)
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
                            .frame(width: width * 0.5, height: height * 0.5)
                        
                    }
                    .frame(width: width * 0.3, height: height * 0.3)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(height * 0.05)
                    
                
                TextField("Email", text: $userEmail)
                    .frame(height: height * 0.04)
                    .padding()
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: width * 0.03))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                
                PasswordView(prompt: "Password", width: width, height: height * 0.04,  userPassword: $userPassword)
                    .padding()
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: width * 0.03))
                
                if menuOption == .create {
                    PasswordView(prompt: "Confirm Password", disableHide: true, width: width, height: height * 0.04, userPassword: $confirmPassword)
                        .padding()
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: width * 0.03))
                        
                }
                
                Button {
                    
                } label: {
                    HStack {
                        Spacer()
                        Text(menuOption.rawValue)
                            .animation(.easeIn, value: menuOption)
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: width * 0.02))
                .padding(.top)
                Spacer()
            }
            .font(.title3)
            .navigationTitle(menuOption.rawValue)
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
    }
}
