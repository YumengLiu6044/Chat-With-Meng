//
//  MessageLogsSectionView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/30/24.
//

import SwiftUI

struct MessageLogsSectionView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    @EnvironmentObject var chatVM:     ChatViewModel
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        let chatMap = chattingVM.chatMap
        
        List {
            ForEach(chatMap) {chat in
                if let index = chatMap.firstIndex(of: chat) {
                    ChatRowView(
                        chatMapItem: $chattingVM.chatMap[index],
                        width: width,
                        height: height * 0.1
                    )
                    .environmentObject(chattingVM)
                }
            }
            
            .onDelete { indexSet in
                for index in indexSet {
                    chattingVM.handleOnChatRowDelete(index)
                }
            }
        }
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .safeAreaInset(edge: .top) {
            SearchBar(text: .constant(""))
        }
        .safeAreaPadding(.bottom, height * 0.1)
    }
}
