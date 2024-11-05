//
//  ChatRowView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/29/24.
//

import SwiftUI

struct ChatRowView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    @Binding var chatMapItem: ChatMapItem
    var width: CGFloat = 300
    var height: CGFloat = 80
    
    @State private var chatObj: Chat = Chat()
    
    var body: some View {
        let lastMessage = chatMapItem.mostRecent
        HStack {
            HStack {
                Circle()
                    .fill()
                    .frame(width: height * 0.15)
                    .foregroundStyle(.myBlue.opacity(lastMessage.isRead ? 0: 1))
                
                ProfilePicView(
                    imageURL: chatObj.chatCoverURL,
                    imageOverlayData: chatObj.chatCoverOverlay,
                    width: width * 0.15,
                    height: width * 0.15
                )
            }
            .padding(.trailing, width * 0.01)
    
            VStack {
                HStack {
                    Text(chatObj.chatTitle)
                        .font(.system(size: height * 0.24))
                        .foregroundStyle(.primary)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(alignment: .topLeading)
                        
                        
                    Spacer()
                    
                    Text(chattingVM.timeAgoDescription(from: lastMessage.time))
                        .font(.system(size: height * 0.24))
                        .foregroundStyle(.primary)
                        .fontWeight(.medium)
                        .frame(alignment: .topTrailing)
                }
                .padding(.bottom, height * 0.01)
                
                Text(lastMessage.content)
                    .font(.system(size: height * 0.24))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity , alignment: .leading)
                
                Spacer()
                
            }
            
            Spacer()
            
            Image(systemName: "chevron.forward")
                .resizable()
                .scaledToFill()
                .frame(width: height * 0.1, height: height * 0.1)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            
        }
        .frame(width: width, height: height)
        .onAppear {
            Task {
                await loadChatObj()
            }
        }
        .onTapGesture {
            chattingVM.showMessageView = true
            chattingVM.chatObjInView = chatObj
        }
    }
    
    private func loadChatObj() async {
        guard let obj = await FirebaseManager.makeChatObject(fromID: self.chatMapItem.chatID) else {return}
        
        self.chatObj = obj
        (self.chatObj.chatCoverURL, self.chatObj.chatCoverOverlay) = await chattingVM.determineCoverPic(forChat: chatObj)
        
    }
}

#Preview {
    ChatRowView(chatMapItem: .constant(ChatMapItem(chatID: "", mostRecent: Message())))
        .environmentObject(ChattingViewModel())
}
