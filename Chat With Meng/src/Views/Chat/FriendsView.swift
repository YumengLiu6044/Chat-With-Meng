//
//  FriendsView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct FriendsView: View {
    
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @EnvironmentObject var chattingVM:    ChattingViewModel

    @State private var width:   CGFloat = 100
    @State private var height:  CGFloat = 100

    @State private var searchKey:   String = ""
    
    @State private var showRequests: Bool   = true
    @State private var showFriends: Bool    = true
    
    @ViewBuilder
    private func searchResults() -> some View {
        ForEach(friendsViewModel.friendSearchResult) { friend in
            if let index = friendsViewModel.friendSearchResult.firstIndex(where: { $0.id == friend.id }) {
                FriendRowView(
                    friend: $friendsViewModel.friendSearchResult[index],
                    width: width,
                    height: height * 0.1,
                    resultState: determineState(of: friendsViewModel.friendSearchResult[index])
                )
                .padding([.leading, .trailing])
                .padding(.top, index == 0 ? height * 0.02 : 0)
                .environmentObject(self.friendsViewModel)
                .environmentObject(self.chatViewModel)
                .environmentObject(self.chattingVM)
                
                if (index != friendsViewModel.friendSearchResult.count - 1) {
                    Divider()
                        .foregroundStyle(.primary)
                        .padding([.leading, .trailing])
                }
            }
        }
    }

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
                                await self.friendsViewModel.searchUsers(
                                    from: searchKey)
                            }
                        }
                    )
                    .padding([.leading, .trailing], width * 0.02)
                    .padding([.top], height * -0.02)

                    ScrollView {
                        if !self.friendsViewModel.friendSearchResult.isEmpty &&
                            !self.searchKey.isEmpty {
                            searchResults()
                        }
                        if self.searchKey.isEmpty &&
                           !self.friendsViewModel.friendRequests.isEmpty {
                            FriendViewSection(showFriends: $showRequests,
                                              friends: $friendsViewModel.friendRequests,
                                              sectionTitle: "Requests",
                                              width: width,
                                              height: height)
                            .environmentObject(self.friendsViewModel)
                            .environmentObject(self.chatViewModel)
                            .environmentObject(self.chattingVM)
                            
                        }
                        if self.searchKey.isEmpty && !self.friendsViewModel.friends.isEmpty {
                            FriendViewSection(showFriends: $showFriends,
                                              friends: self.$friendsViewModel.friends,
                                              sectionTitle: "Friends",
                                              width: width,
                                              height: height,
                                              hideTitle: self.friendsViewModel.friendRequests.isEmpty
                            )
                            .environmentObject(self.friendsViewModel)
                            .environmentObject(self.chatViewModel)
                            .environmentObject(self.chattingVM)
                        }
                    }
                    .listRowSpacing(height * 0.05)
                    .scrollIndicators(.hidden)
                    .scrollClipDisabled()
                    Spacer()
                }
                .navigationDestination(isPresented: $chattingVM.showMessageView) {
                    MessageView(width: width, height: height)
                        .environmentObject(chattingVM)
                        .onAppear {
                            withAnimation(.smooth) {
                                chatViewModel.showMenu = false
                            }
                        }
                        .onDisappear {
                            withAnimation(.smooth) {
                                chatViewModel.showMenu = true
                            }
                        }
                }
                .navigationDestination(isPresented: $friendsViewModel.showProfile, destination: {
                    ProfileView(friend: $friendsViewModel.friendInView, rowState: friendsViewModel.rowState)
                        .onDisappear {
                            let exitFriend = self.friendsViewModel.friendInView
                            if friendsViewModel.friendRemovalQueue.contains(exitFriend) {
                                friendsViewModel.removeFriendFromLocal(exitFriend)
                            }
                            if self.friendsViewModel.requestRemovalQueue.contains(exitFriend) {
                                friendsViewModel.removeFriendRequestFromLocal(exitFriend)
                            }
                            friendsViewModel.showProfile = false
                            friendsViewModel.friendInView = Friend()
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
    
    private func determineState(of friend: Friend) -> FriendRowState {
        if self.friendsViewModel.friendRequests.contains(friend) {
            return .requested
        }
        else if self.friendsViewModel.friends.contains(friend) {
            return .friended
        }
        else {
            return .searched
        }
    }
}
