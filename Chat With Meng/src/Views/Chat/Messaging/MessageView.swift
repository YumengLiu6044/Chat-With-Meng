//
//  MessageView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/31/24.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    
    var width: CGFloat
    var height: CGFloat
    
    @FocusState private var focus: FocusField?
    @State private var messages: [Message] = []
    
    @ViewBuilder
    func header() -> some View {
        let chatInView = chattingVM.chatObjInView
        HStack {
            ProfilePicView(
                imageURL: chatInView.chatCoverURL,
                imageOverlayData: chatInView.chatCoverOverlay,
                width: width * 0.12,
                height: width * 0.12
            )
            // .padding(.leading, width * 0.12)
            
            Text(chatInView.chatTitle)
                .font(.title)
                .fontWeight(.medium)
                .lineLimit(1)
                .padding(.leading)
                // .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, height * 0.03)
        .background {
            Rectangle()
                .fill()
                .foregroundStyle(.ultraThickMaterial)
                .frame(width: width)
                .ignoresSafeArea(edges: [.top])
        }
        // .frame(maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, height * -0.055)
    }
    
    @ViewBuilder
    func entryBox() -> some View {
        let messageText = chattingVM.messageText
        HStack {
            IconView(iconName: "photo")
                .padding(.trailing, width * 0.02)
                .shadow(radius: 2)
            
            TextField(
                "Name", text: $chattingVM.messageText,
                prompt: Text("Message").foregroundStyle(.gray)
            )
            .submitLabel(.send)
            .onSubmit {
                
                Task {
                    if let chatID = chattingVM.chatObjInView.chatID {
                        await chattingVM.sendMessage(messageContent: messageText, chatID: chatID)
                        
                        chattingVM.messageText = ""
                        
                    }
                    
                }
            }
            .frame(height: height * 0.015)
            .padding()
            .background(.ultraThickMaterial)
            .clipShape(.rect(cornerRadius: width * 0.03))
            .shadow(radius: 3)
            .overlay {
                RoundedRectangle(cornerRadius: width * 0.03)
                    .stroke(.blue.opacity(0.8), lineWidth: (focus == .messageField) ? 2 : 0)
            }
            .focused($focus, equals: .messageField)
            .onDisappear {
                focus = nil
            }
            
            IconView(iconName: "paperplane.fill", color: .blue) {
                Task {
                    if let chatID = chattingVM.chatObjInView.chatID {
                        await chattingVM.sendMessage(messageContent: messageText, chatID: chatID)
                        
                        chattingVM.messageText = ""
                        // Optionally exits focus after sending message
                        // focus = nil
                    }
                    
                }
            }
                .shadow(radius: 2)
                .disabled(messageText.isEmpty)
                
        }
        // .frame(maxHeight: .infinity, alignment: .bottom)
        .padding([.leading, .trailing, .bottom])
    }
    
    var body: some View {
        let chatInView = chattingVM.chatObjInView
        let messagesInView = chattingVM.messagesInView
        
        VStack {
            header()
            
            ScrollViewReader{
                proxy in
                ScrollView {
                    ForEach(messagesInView) {
                        message in
                        let showProfile = chattingVM.determineIsShowProfile(message)
                        let showTime = chattingVM.determineShowTime(message)
                        if showTime {
                            let description = chattingVM.timeAgoDescription(from: message.time, detailed: true)
                            Text(description)
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                        MessageRowView(
                            message: message,
                            width: width,
                            senderIsSelf: chattingVM.idIsSelf(other: message.fromUserID),
                            showProfile: showProfile
                        )
                        .environmentObject(chattingVM)
                        .id(message.id)
                    }
                    
                }
                .safeAreaPadding(.bottom, height * 0.01)
                .onChange(of: chattingVM.messagesInView) {
                    guard let messageID = messagesInView.last?.id else {return}
                    withAnimation(.smooth) {
                        proxy.scrollTo(messageID, anchor: .bottom)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                
            }
            entryBox()
                .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                    .onEnded { value in
                        print(value.translation)
                        switch(value.translation.width, value.translation.height) {
                        case (-100...100, 0...):  focus = nil
                        default:  print("no clue")
                        }
                    }
                )
        }
        .onAppear {
            Task {
                guard let chatID = chatInView.chatID else {return}
                (chattingVM.chatObjInView.chatCoverURL, chattingVM.chatObjInView.chatCoverOverlay) = await chattingVM.determineCoverPic(forChat: chatInView)
                let messages = await chattingVM.loadChatLogs(forChat: chatID)
                chattingVM.messagesInView = messages ?? []
                let _ = chattingVM.messagesInView.map{chattingVM.markAsRead(message: $0)}
                chattingVM.chatObjInView.chatTitle = await chattingVM.determineGroupName(forChat: chattingVM.chatObjInView)
//                chattingVM.markAsRead(message: chattingVM.messagesInView.last ?? Message())
            }
        }
        .onDisappear {
            chattingVM.messagesInView = []
            chattingVM.chatObjInView = Chat()
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarRole(.editor)
    }
}

#Preview {
    MessageView(width: 400, height: 700)
        .environmentObject(ChattingViewModel())
}
