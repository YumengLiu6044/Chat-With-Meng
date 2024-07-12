//
//  PasswordView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/11/24.
//

import SwiftUI

struct PasswordView: View {
    @Binding var userPassword: String
    @State var isShowingPassword: Bool = false
    
    var body: some View {
        HStack {
            if !isShowingPassword {
                SecureField("Password", text: $userPassword)
                    .padding()
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 5))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                                    
            }
            else {
                TextField("Password", text: $userPassword)
                    .padding()
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 5))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
            }
            
            Spacer()
            Button {
                isShowingPassword.toggle()
            } label: {
                Image(systemName: isShowingPassword ? "eye" : "eye.slash")
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(.black)
                    
            }
            .frame(height:5)
        }
    }
}

#Preview {
    PasswordView(userPassword: .constant("sample_password"))
        
}
