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
    @ObservedObject var chattingViewModel: ChattingViewModel = ChattingViewModel()
    @ObservedObject var friendsViewModel: FriendsViewModel = FriendsViewModel()
    @ObservedObject var settingVM: SettingViewModel = SettingViewModel()

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
                        .environmentObject(friendsViewModel)
                        .environmentObject(chattingViewModel)
                        .transition(.move(edge: .leading))
                case .friends:
                    FriendsView()
                        .environmentObject(chatViewModel)
                        .environmentObject(friendsViewModel)
                        
                case .settings:
                    SettingsView()
                        .environmentObject(appViewModel)
                        .environmentObject(settingVM)
                        .transition(.move(edge: .trailing))
                }
                
                if self.chatViewModel.showMenu {
                    MenuBarView(width: width * 0.9, height: height * 0.1)
                        .environmentObject(chatViewModel)
                        .environmentObject(friendsViewModel)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .ignoresSafeArea(.keyboard)
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
            .onDisappear {
                self.friendsViewModel.removeListeners()
                self.chattingViewModel.removeListeners()
            }
            .toastView(toast: $chatViewModel.toast)
            .toastView(toast: $chattingViewModel.toast)
            .toastView(toast: $friendsViewModel.toast)
            .toastView(toast: $settingVM.toast)
        }

    }
    
    
    
}

#Preview {
    ChatViewMain()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
