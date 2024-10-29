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
                            let isComposing = chattingViewModel.isComposing
                            let recipientList = chattingViewModel.recipientList
                            
                            if isComposing {
                                if !recipientList.isEmpty {
                                    print("New chat")
                                }
                            }
                            else {
                                withAnimation(.snappy) {
                                    chattingViewModel.isComposing.toggle()
                                }
                            }
                        }
                        label: {
                            if chattingViewModel.isComposing {
                                Label("New Chat", systemImage: "paperplane")
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
                        .tint(.primary)
                        
                    }
                    .padding([.top, .leading, .trailing])
                    
                    if chattingViewModel.isComposing {
                        ComposeGroupView(width: width, height: height)
                            .environmentObject(chattingViewModel)
                            .environmentObject(chatViewModel)
                    }
                    else {
                        
                    }
                    Spacer()
                    
                }
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                    
                    print("\((width, height))")
                }
            }
        }
        
    }
}

#Preview {
    ChatView()
}
