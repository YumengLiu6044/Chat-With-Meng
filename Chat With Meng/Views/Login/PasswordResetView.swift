//
//  PasswordResetView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/13/24.
//

import SwiftUI

struct PasswordResetView: View {
    
    @Binding var isForgetPassword:  Bool
    
    @State private var email:       String      =   ""
    
    @State private var width:       CGFloat     =   100
    @State private var height:      CGFloat     =   100
    
    @State private var toast:       Toast?      =   nil
    
    var body: some View {
        GeometryReader{
            geometry in
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
                
                Text("Input your email below, if it exists, a reset link will be sent to it")
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
                
                Button {
                    toast = Toast(style: .success, message: "Email sent")
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
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
            }
            .toastView(toast: $toast)
        }
        
        
        
    }
}

#Preview {
    PasswordResetView(isForgetPassword: .constant(true))
}
