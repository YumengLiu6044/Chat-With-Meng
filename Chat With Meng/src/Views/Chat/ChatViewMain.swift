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
    
    @State private var didAppear: Bool = false
    
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
                        .environmentObject(chatViewModel)
                        
                case .settings:
                    SettingsView()
                        .environmentObject(appViewModel)
                        .environmentObject(chatViewModel)
                        .transition(.move(edge: .trailing))
                }
                
                
                VStack {
                    Spacer()
                    if self.chatViewModel.showMenu {
                        MenuBarView(width: width * 0.9, height: height * 0.1)
                            .environmentObject(chatViewModel)
                    }
                        
                }
                .ignoresSafeArea(.keyboard)
            }
            .background(
                Color(.init(white: 0, alpha: 0.1))
                    .ignoresSafeArea()
            )
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
                
                if (!didAppear) {
                    self.chatViewModel.initializeCurrentUser()
                    didAppear = true
                }
            }
            .onDisappear {
                self.chatViewModel.deinitializeCurrentUser()
            }
            .toastView(toast: $chatViewModel.toast)
        }

    }
    
    
    
}

#Preview {
    ChatViewMain()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
