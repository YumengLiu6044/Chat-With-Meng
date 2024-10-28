//
//  ComposeGroupView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/25/24.
//

import SwiftUI

struct ComposeGroupView: View {
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack {
            SearchBar(
                text: $chattingViewModel.searchkey,
                onCancelAction: {
                    chattingViewModel.searchkey = ""
                    chattingViewModel.recipientList = []
                    chattingViewModel.searchResults = []
                    withAnimation(.smooth) {
                        chattingViewModel.isComposing = false
                    }
                },
                onSearchAction: {
                    chattingViewModel.searchForFriends(from: chatViewModel.friends)
                    
                }
            )
            .padding([.leading, .trailing], width * 0.02)
            .padding([.top], height * -0.02)
            
            List {
                ForEach(chattingViewModel.searchResults) {
                    friend in
                    Text(friend.userName)
                }
            }
        }
    }
}

#Preview {
    ComposeGroupView(width: 402, height: 778)
        .environmentObject(ChattingViewModel())
        .environmentObject(ChatViewModel())
}
