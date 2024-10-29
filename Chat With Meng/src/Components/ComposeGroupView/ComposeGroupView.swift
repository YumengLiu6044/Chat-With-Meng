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
                    withAnimation(.smooth) {
                        chattingViewModel.isComposing = false
                    }
                },
                onSearchAction: {
                    chattingViewModel.searchForFriends(from: chatViewModel.friends)
                    
                }
            )
            .padding([.leading, .trailing], width * 0.02)
            
            ScrollView(.horizontal) {
                if !chattingViewModel.recipientList.isEmpty {
                    Text("Recipients")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: width * 0.02) {
                    ForEach(chattingViewModel.recipientList) {
                        friend in
                        VerticalProfileView(friend: friend, width: width * 0.2, height: height * 0.1) {
                            chattingViewModel.moveRecipientToSearchResult(for: friend)
                        }
                    }
                }
            }
            .padding([.leading, .trailing])
            
            ScrollView {
                Text("Friends")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                
                VStack(spacing: height * 0.05) {
                    ForEach(chattingViewModel.searchResults) {
                        friend in
                        HorizontalProfileView(friend: friend, width: width, height: height * 0.1) {
                            chattingViewModel.moveSearchResultToRecipient(for: friend)
                        }
                        .padding([.leading, .trailing])
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            chattingViewModel.searchkey = ""
            chattingViewModel.searchResults = chatViewModel.friends
        }
        .onDisappear {
            chattingViewModel.searchkey = ""
            chattingViewModel.searchResults = chatViewModel.friends
            chattingViewModel.recipientList = []
            
        }
    }
}

#Preview {
    ComposeGroupView(width: 402, height: 778)
        .environmentObject(ChattingViewModel())
        .environmentObject(ChatViewModel())
}
