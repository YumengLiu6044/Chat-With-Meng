//
//  PasswordResetView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/13/24.
//

import SwiftUI

struct PasswordResetView: View {
    
    @Binding var isForgetPassword:  Bool
    
    var width:    CGFloat
    var height:   CGFloat
    
    @State private var email:       String          =   ""
    @State private var toast:       Toast?          =   nil
    
    @FocusState private var focus:    FocusField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: height * 0.02) {
                HStack {
                    Text("Forgot Password")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        isForgetPassword = false
                    } label: {
                        Text("Cancel")
                    }
                }
                .padding()
            
                Text("Type your email below, if it exists, a reset link will be sent to it")
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding()
                
                TextField("Email", text: $email, prompt: Text("Email").foregroundStyle(.gray))
                    .frame(height: height * 0.02)
                    .padding()
                    .background(.ultraThickMaterial)
                    .clipShape(.rect(cornerRadius: width * 0.03))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                    .overlay {
                        RoundedRectangle(cornerRadius: width * 0.03)
                            .stroke(.blue.opacity(0.8), lineWidth: (focus == .email) ? 2 : 0)
                    }
                    .focused($focus, equals: .email)
                    .onDisappear {
                        focus = nil
                    }
                
                Button {
                    sendResetEmail()
                } label: {
                    HStack {
                        Spacer()
                        Text("Send reset email")
                            .font(.title2)
                            
                        Spacer()
                    }
                    
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: width * 0.03))
                
                Spacer()
            }
            .padding()
            .toastView(toast: $toast)
        
    }
    
    func sendResetEmail() {
        
        guard !email.isEmpty else {
            toast = Toast(style: .error, message: "The email address is empty")
            return
        }
        
        guard email.contains("@") else {
            toast = Toast(style: .error, message: "The email address is badly formatted")
            return
        }
        
        FirebaseManager.shared.auth.sendPasswordReset(withEmail: email) {error in
            if let error = error {
                toast = Toast(style: .error, message: error.localizedDescription)
                return
            }
            else {
                toast = Toast(style: .success, message: "Reset email sent")
            }
            
        }
    }
}

#Preview {
    PasswordResetView(isForgetPassword: .constant(true), width: 200, height:500)
}
