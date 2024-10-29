//
//  ChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @ObservedObject var chattingViewModel: ChattingViewModel = ChattingViewModel()
    
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    
    var body: some View {
        let isComposing = chattingViewModel.isComposing
        let recipientList = chattingViewModel.recipientList
        
        GeometryReader {
            geometry in 
            NavigationStack {
                VStack {
                    HStack {
                        Text("Chat")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            if isComposing {
                                if !recipientList.isEmpty{
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
                            .environmentObject(chatViewModel)
                    }
                    else {
                        
                    }
                    Spacer()
                    
                }
                .navigationDestination(isPresented: $chattingViewModel.showNewChat) {
                    NewChatView(
                        width: width,
                        height: height
                    )
                }
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                }
            }
            .tint(.primary)
        }
        
    }
}

#Preview {
    ChatView()
}
