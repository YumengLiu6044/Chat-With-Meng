//
//  ChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var friendsVM:           FriendsViewModel
    @EnvironmentObject var chattingViewModel:   ChattingViewModel
    @EnvironmentObject var chatVM:              ChatViewModel

    
    var body: some View {
        let isComposing = chattingViewModel.isComposing
        let recipientList = chattingViewModel.recipientList
        
        GeometryReader {
            geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            NavigationStack {
                VStack {
                    HStack {
                        Text("Chat")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            if isComposing {
                                if !recipientList.isEmpty {
                                    Task {
                                        await chattingViewModel.processSendButtonClick()
                                    }
                                }
                            }
                            else {
                                withAnimation(.snappy) {
                                    chattingViewModel.isComposing.toggle()
                                }
                            }
                        }
                        label: {
                            if isComposing {
                                Label("Send", systemImage: "paperplane")
                                    .fontWeight(.semibold)
                                    .padding()
                                    .background(.ultraThickMaterial, in: .capsule)
                                    .tint(chattingViewModel.recipientList.isEmpty ? .secondary : .primary)
                            }
                            else {
                                Image(systemName: "paperplane")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 35, height: 35)
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(isComposing && recipientList.isEmpty)
                        .tint(.primary)
                        
                    }
                    .padding([.top, .leading, .trailing])
                    
                    if isComposing {
                        ComposeGroupView(width: width, height: height)
                            .environmentObject(chattingViewModel)
                            .environmentObject(friendsVM)
                    }
                    else {
                        MessageLogsSectionView(width: width, height: height)
                            .environmentObject(chattingViewModel)
                            .environmentObject(chatVM)
                    }
                    Spacer()
                    
                }
                .navigationDestination(isPresented: $chattingViewModel.showMessageView) {
                    MessageView(width: width, height: height)
                        .environmentObject(chattingViewModel)
                        .onAppear {
                            withAnimation(.smooth) {
                                chatVM.showMenu = false
                            }
                        }
                        .onDisappear {
                            withAnimation(.smooth) {
                                chatVM.showMenu = true
                            }
                        }
                }
                .navigationDestination(isPresented: $chattingViewModel.showNewChat) {
                    NewChatView(
                        width: width,
                        height: height
                    )
                    .environmentObject(chattingViewModel)
                }
            }
            .tint(.primary)
        }
        
    }
}
