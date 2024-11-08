//
//  ComposeGroupView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/25/24.
//

import SwiftUI

struct ComposeGroupView: View {
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack {
            SearchBar(
                text: $chattingViewModel.searchkey,
                alwaysShowCancel: true,
                onCancelAction: {
                    withAnimation(.smooth) {
                        chattingViewModel.isComposing = false
                    }
                },
                onSearchAction: {
                    chattingViewModel.searchForFriends(from: friendVM.friends)
                    
                }
            )
            .tint(.primary)
            .padding([.leading, .trailing], width * 0.02)
            
            if !chattingViewModel.recipientList.isEmpty {
                Text("Recipients: \(recipientMessage())")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            ScrollView(.horizontal) {
                HStack(spacing: width * 0.02) {
                    ForEach(chattingViewModel.recipientList) {
                        friend in
                        VerticalProfileView(friend: friend, width: width * 0.22, height: height * 0.1) {
                            chattingViewModel.moveRecipientToSearchResult(for: friend)
                        }
                        .scrollTransition {
                            content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1: 0.5)
                        }
                    }
                    .padding([.top, .bottom], height * 0.01)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .padding([.leading, .trailing])
            
            ScrollView {
                Text("Friends")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                
                ForEach(chattingViewModel.searchResults) {
                    friend in
                    HorizontalProfileView(friend: friend, width: width, height: height * 0.1) {
                        chattingViewModel.moveSearchResultToRecipient(for: friend)
                    }
                    .padding([.leading, .trailing])
                    if (friend != chattingViewModel.searchResults.last) {
                        Divider()
                            .foregroundStyle(.primary)
                            .padding([.leading, .trailing])
                    }
                }
            }
            .listRowSpacing(height * 0.035)
            .scrollIndicators(.hidden)
        }
        .onAppear {
            chattingViewModel.searchkey = ""
            chattingViewModel.searchResults = friendVM.friends
        }
        .onDisappear {
            chattingViewModel.searchkey = ""
            chattingViewModel.searchResults = friendVM.friends
            chattingViewModel.recipientList = []
            
        }
    }
    
    private func recipientMessage() -> String {
        var msg: String = ""
        if chattingViewModel.recipientList.count >= 1 {
            msg += chattingViewModel.recipientList[0].userName
        }
        if chattingViewModel.recipientList.count >= 2 {
            msg += ", " + chattingViewModel.recipientList[1].userName
        }
        if chattingViewModel.recipientList.count > 2 {
            msg += ", and others"
        }
        return msg
        
    }
}

#Preview {
    ComposeGroupView(width: 402, height: 778)
        .environmentObject(ChattingViewModel())
        .environmentObject(ChatViewModel())
}
