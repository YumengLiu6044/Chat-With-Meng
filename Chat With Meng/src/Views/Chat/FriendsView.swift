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

    @State private var width:   CGFloat = 100
    @State private var height:  CGFloat = 100

    @State private var searchKey:   String = ""
    
    @State private var showRequests: Bool   = true
    @State private var showFriends: Bool    = true

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
                    .padding([.leading, .trailing], width * 0.02)
                    .padding([.top], height * -0.02)

                    ScrollView {
                        if !self.chatViewModel.friendSearchResult.isEmpty &&
                            !self.searchKey.isEmpty {
                            ForEach(chatViewModel.friendSearchResult) { friend in
                                if let index = chatViewModel.friendSearchResult.firstIndex(where: { $0.id == friend.id }) {
                                    FriendRowView(
                                        friend: $chatViewModel.friendSearchResult[index],
                                        width: width,
                                        height: height * 0.1
                                    )
                                    .padding([.leading, .trailing])
                                    .padding(.top, index == 0 ? height * 0.02 : 0)
                                    .environmentObject(self.chatViewModel)
                                    
                                    if (index != chatViewModel.friendSearchResult.count - 1) {
                                        Divider()
                                            .foregroundStyle(.primary)
                                            .padding([.leading, .trailing])
                                    }
                                }
                            }
                        }
                        if self.searchKey.isEmpty &&
                           !self.chatViewModel.friendRequests.isEmpty {
                            FriendViewSection(showFriends: $showRequests,
                                              friends: $chatViewModel.friendRequests,
                                              sectionTitle: "Requests",
                                              width: width,
                                              height: height)
                            
                        }
                        if self.searchKey.isEmpty && !self.chatViewModel.friends.isEmpty {
                            FriendViewSection(showFriends: $showFriends,
                                              friends: self.$chatViewModel.friends,
                                              sectionTitle: "Friends",
                                              width: width,
                                              height: height,
                                              hideTitle: self.chatViewModel.friendRequests.isEmpty
                            )
                        }
                    }
                    .listRowSpacing(height * 0.05)
                    .scrollIndicators(.hidden)
                    Spacer()
                }
                
                .navigationDestination(isPresented: $chatViewModel.showProfile, destination: {
                    ProfileView(friend: $chatViewModel.friendInView, rowState: chatViewModel.rowState)
//                        .onAppear {
//                            withAnimation(.smooth) {
//                                chatViewModel.showMenu = false
//                            }
//                        }
                        .onDisappear {
//                            withAnimation(.smooth) {
//                                chatViewModel.showMenu = true
//                            }
                            let exitFriend = self.chatViewModel.friendInView
                            if chatViewModel.removalQueue.contains(exitFriend) {
                                chatViewModel.removeFriendFromLocal(exitFriend)
                            }
                        }
                })
                .scrollContentBackground(.hidden)
                .background(
                    Color(.init(white: 0, alpha: 0.1))
                        .ignoresSafeArea()
                )
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                }
                
            }
    
            .tint(.primary)

        }

    }
}

#Preview {
    FriendsView()
        .environmentObject(ChatViewModel())

}
