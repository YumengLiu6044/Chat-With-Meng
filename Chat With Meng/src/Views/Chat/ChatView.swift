//
//  ChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/5/24.
//

import SwiftUI

struct ChatView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var width:               CGFloat     =   100
    @State private var height:              CGFloat     =   100
    
    @AppStorage("saved_email") var savedEmail : String = ""
    @AppStorage("saved_password") var savedPassword : String = ""
    
   
    var body: some View {
        GeometryReader {
            geometry in
            
            NavigationStack {
                VStack {
                    
                }
                .toolbar {
                    Button {
                        signOut()
                        appViewModel.switchTo(view: .login)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                    }
                    
                }
                .navigationTitle(
                    Text("Chat")
                )
                
            }
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
            }
        }
        
    }
    
    private func signOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            savedPassword = ""
            savedEmail    = ""
            
        }
        catch {
            print("Failed to sign out")
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
