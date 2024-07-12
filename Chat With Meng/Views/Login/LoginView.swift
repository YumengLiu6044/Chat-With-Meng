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
    
    @State private var menuOption: MenuOptions  =   .login
    @State private var userEmail: String        =   ""
    @State private var userPassword: String     =   ""
    @State private var isLoginSuccess: Bool     =   false
    @State private var isShowPassword: Bool     =   false
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 10) {
                Picker(selection: $menuOption, label: Text("Login")) {
                    ForEach(MenuOptions.allCases, id: \.self) {
                        option in
                        Text(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                Image(systemName: imageDisplayPredicate(isLoginSuccess: isLoginSuccess, menuOption: menuOption))
                    .padding()
                    .font(.system(size: 80))
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 4)
                            .shadow(radius: 3)
                            .frame(width:150, height: 150)
                        
                    }
                    .frame(width:80, height: 80)
                    .padding(50.0)
                    .contentTransition(.symbolEffect(.replace))
                
                TextField("Email", text: $userEmail)
                    .padding()
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 5))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                
                PasswordView(userPassword: $userPassword)
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 5))
                    
                
                
                
                Button {
                    isLoginSuccess.toggle()
                    isShowPassword.toggle()
                    
                } label: {
                    HStack {
                        Spacer()
                        Text(menuOption.rawValue)
                            .animation(.easeIn, value: menuOption)
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
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
    LoginView()
}
