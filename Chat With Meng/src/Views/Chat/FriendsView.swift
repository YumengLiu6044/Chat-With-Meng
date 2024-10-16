//
//  FriendsView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct FriendsView: View {

    @EnvironmentObject var chatViewModel: ChatViewModel
    @ObservedObject var friendsViewModel: FriendsViewModel = FriendsViewModel()

    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    @State private var searchKey: String = ""

    var body: some View {
        GeometryReader {
            geometry in
            NavigationStack {
                VStack {
                    HStack {

                        Text("Friends")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Spacer()

                    }
                    .padding([.top, .leading, .trailing])

                    SearchBar(
                        text: $searchKey,
                        onCancelAction: {
                            self.searchKey = ""
                        },
                        onSearchAction: {
                            Task {
                                await self.chatViewModel.searchUsers(
                                    from: searchKey)
                            }

                        }
                    )
                    .onChange(of: self.searchKey) {
                        self.chatViewModel.friendSearchResult = []
                    }
                    .padding([.leading, .trailing], width * 0.02)
                    .padding([.top], height * -0.02)

                    ScrollView {
                        if !searchKey.isEmpty {
                            ForEach(chatViewModel.friendSearchResult) {
                                friend in
                                FriendSearchResult(
                                    friend: friend, width: width,
                                    height: height * 0.1
                                )
                                .padding([.leading, .trailing])

                                .environmentObject(self.chatViewModel)
                                
                                if (friend.id != chatViewModel.friendSearchResult.last?.id || !self.chatViewModel.friendSearchResult.isEmpty) {
                                    Divider()
                                        .padding([.leading, .trailing])
                                    
                                }
                            }

                        }
                        ForEach (
                            chatViewModel.friendRequests, id: \.self
                        ) {
                            request in
                            FriendRequestView(
                                friend: request,
                                width: width,
                                height: height * 0.1
                            )
                            .padding([.leading, .trailing])
                            
                            if (request.id != chatViewModel.friendRequests.last?.id) {
                                Divider()
                                    .padding([.leading, .trailing])
                            }
                        }
                        .onChange(of: chatViewModel.currentUser.friendRequests) {
                            self.chatViewModel.loadFriendRequests()
                        }
                    }
                    .listRowSpacing(height * 0.02)
                    .scrollIndicators(.hidden)
                    
                    Spacer()

                }
                .scrollContentBackground(.hidden)
                .background(
                    Color(.init(white: 0, alpha: 0.1))
                        .ignoresSafeArea()
                )
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                    
                    self.chatViewModel.loadFriendRequests()
                }
            }

        }

    }
}

#Preview {
    FriendsView()
        .environmentObject(ChatViewModel())

}
