//
//  PasswordView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/11/24.
//

import SwiftUI

struct PasswordField: View {
    var prompt: String
    var disableHide: Bool = false
    var width: CGFloat
    var height: CGFloat
    
    @Binding var userPassword: String
    @State var isShowingPassword: Bool = false
    
    var body: some View {
        HStack {
            if isShowingPassword {
                TextField(prompt, text: $userPassword, prompt: Text(prompt).foregroundStyle(.gray))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                    .frame(height: height)
            }
            else {
                SecureField(prompt, text: $userPassword, prompt: Text(prompt).foregroundStyle(.gray))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                    .frame(height: height)
            }
            Spacer()
            if !disableHide{
                Button {
                    isShowingPassword.toggle()
                } label: {
                    Image(systemName: isShowingPassword ? "eye" : "eye.slash")
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundStyle(.foreground)
                        .frame(height: height)
                }
            }
        }
        
    }
}

#Preview {
    GeometryReader{ geometry in
        PasswordField(prompt: "Password", width: geometry.size.width, height: geometry.size.height, userPassword: .constant("sample_password"))
    }
    
}
