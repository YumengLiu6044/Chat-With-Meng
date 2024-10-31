//
//  ChatRowView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/29/24.
//

import SwiftUI

struct ChatRowView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    var chatMapItem: ChatMapItem
    var width: CGFloat = 300
    var height: CGFloat = 80
    
    @State private var chatObj: Chat = Chat()
    
    var body: some View {
        HStack {
            HStack {
                if let lastMessage = chatMapItem.chatLogs.last{
                    Circle()
                        .fill()
                        .frame(width: height * 0.15)
                        .foregroundStyle(.myBlue.opacity(lastMessage.isRead ? 0: 1))
                }
                
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
                    
                    if let lastMessage = chatMapItem.chatLogs.last {
                        Text(timeAgoDescription(from: lastMessage.time))
                            .font(.system(size: height * 0.24))
                            .foregroundStyle(.primary)
                            .fontWeight(.medium)
                            .frame(alignment: .topTrailing)
                    }
                }
                .padding(.bottom, height * 0.01)
                
                
                if let lastMessage = chatMapItem.chatLogs.last {
                    Text(lastMessage.content)
                        .font(.system(size: height * 0.24))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity , alignment: .leading)
                }
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
    }
    
    private func timeAgoDescription(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
        let dateFormatter = DateFormatter()
        
        if let week = components.weekOfYear, week > 0 {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: date)
        }
        
        if let day = components.day {
            switch day {
            case 0:
                dateFormatter.dateFormat = "h:mm a"
                return dateFormatter.string(from: date)
                
            case 1:
                return "Yesterday"
                
            default:
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: date)
            }
        }
        return date.formatted(.iso8601)
    }

    
    private func loadChatObj() async {
        guard let obj = await FirebaseManager.makeChatObject(fromID: self.chatMapItem.chatID) else {return}
        
        self.chatObj = obj
        
    }
}

#Preview {
    ChatRowView(chatMapItem: ChatMapItem(chatID: ""))
        .environmentObject(ChattingViewModel())
}
