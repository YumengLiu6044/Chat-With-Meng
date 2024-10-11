//
//  ChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/5/24.
//

import SwiftUI

struct ChatViewMain: View {

    @EnvironmentObject var appViewModel: AppViewModel
    @ObservedObject var chatViewModel: ChatViewModel = ChatViewModel()

    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    @AppStorage("saved_email") var savedEmail: String = ""
    @AppStorage("saved_password") var savedPassword: String = ""

    var body: some View {
        GeometryReader {
            geometry in

            ZStack{
                switch chatViewModel.chatViewSelection {
                case .messages:
                    ChatView()
                case .friends:
                    FriendsView()
                case .settings:
                    SettingsView()
                }
                
                
                VStack {
                    Spacer()
                    MenuBarView(width: width * 0.9, height: height * 0.1)
                        .environmentObject(chatViewModel)
                        
                }
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
            savedEmail = ""

        } catch {
            print("Failed to sign out")
        }
    }
}

#Preview {
    ChatViewMain()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
