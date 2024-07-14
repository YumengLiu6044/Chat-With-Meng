//
//  PasswordResetView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/13/24.
//

import SwiftUI

struct PasswordResetView: View {
    @Binding var isForgetPassword: Bool
    
    var body: some View {
        VStack{
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
            
            Spacer()
        }
        
        
    }
}

#Preview {
    PasswordResetView(isForgetPassword: .constant(true))
}
