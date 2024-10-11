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

    
    var body: some View {
        GeometryReader {
            geometry in

            ZStack{
                switch chatViewModel.chatViewSelection {
                case .messages:
                    ChatView()
                        .transition(.move(edge: .leading))
                case .friends:
                    FriendsView()
                        
                case .settings:
                    SettingsView()
                        .transition(.move(edge: .trailing))
                }
                
                
                VStack {
                    Spacer()
                    MenuBarView(width: width * 0.9, height: height * 0.1)
                        .environmentObject(chatViewModel)
                        
                }
            }
            .background(
                Color(.init(white: 0, alpha: 0.1))
                    .ignoresSafeArea()
            )
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
            }
        }

    }

    
}

#Preview {
    ChatViewMain()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}