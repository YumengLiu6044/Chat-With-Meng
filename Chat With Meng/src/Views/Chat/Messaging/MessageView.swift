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
                width: width * 0.11,
                height: width * 0.11
            )
            // .padding(.leading, width * 0.12)
            
            Text(chatInView.chatTitle)
                .font(.title)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.leading)
                // .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom)
        .background {
            Rectangle()
                .fill()
                .foregroundStyle(.ultraThickMaterial)
                .frame(width: width)
                .ignoresSafeArea(edges: [.top])
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, height * -0.055)
    }
    
    @ViewBuilder
    func entryBox() -> some View {
        TextField(
            "Name", text: $chattingVM.messageText,
            prompt: Text("Message").foregroundStyle(.gray)
        )
        .submitLabel(.send)
        .onSubmit {
            print("Sending message:\n\(chattingVM.messageText)")
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
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding([.leading, .trailing, .bottom])
        .focused($focus, equals: .messageField)
        .onDisappear {
            focus = nil
        }
    }
    
    var body: some View {
        let chatInView = chattingVM.chatObjInView
        let messagesInView = chattingVM.messagesInView
        
        ScrollView {
            LazyVStack {
                ForEach(messagesInView) {
                    message in
                    Text(message.content)
                        .foregroundStyle(.primary)
                }
            }
        }
        .onAppear {
            Task {
                guard let chatID = chatInView.chatID else {return}
                let messages = await chattingVM.loadChatLogs(forChat: chatID)
                chattingVM.messagesInView = messages ?? []
                print(messages ?? [])
            }
        }
        .onDisappear {
            chattingVM.messagesInView = []
            chattingVM.chatObjInView = Chat()
        }
        .safeAreaInset(edge: .top) {
            header()
        }
        .safeAreaInset(edge: .bottom) {
            entryBox()
        }
        .toolbarRole(.editor)
    }
}

#Preview {
    MessageView(width: 400, height: 700)
        .environmentObject(ChattingViewModel())
}
