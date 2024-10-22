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
    
    @State private var showRequests: Bool = true
    @State private var showFriends: Bool = true

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
                        if !self.searchKey.isEmpty {
                            ForEach(chatViewModel.friendSearchResult.indices, id: \.self) { index in
                                FriendRowView(
                                    friend: $chatViewModel.friendSearchResult[index],
                                    width: width,
                                    height: height * 0.1
                                )
                                .padding([.leading, .trailing])
                                .environmentObject(self.chatViewModel)
                                
                                if (index != chatViewModel.friendSearchResult.count - 1) {
                                    Divider()
                                        .foregroundStyle(.primary)
                                        .padding([.leading, .trailing])
                                }
                            }
                        }
                        if self.searchKey.isEmpty &&
                           !self.chatViewModel.friendRequests.isEmpty {
                            Section(
                                content: {
                                    if self.showRequests {
                                        ForEach(chatViewModel.friendRequests.indices, id: \.self) { index in
                                            FriendRowView(
                                                friend: $chatViewModel.friendRequests[index],
                                                width: width,
                                                height: height * 0.1
                                            )
                                            .padding([.leading, .trailing])
                                            
                                            if (index != chatViewModel.friendRequests.count - 1) {
                                                Divider()
                                                    .foregroundStyle(.primary)
                                                    .padding([.leading, .trailing])
                                            }
                                        }
                                    }
                                
                            }, header: {
                                HStack {
                                    Text("Requests")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.smooth) {
                                            self.showRequests.toggle()
                                        }
                                    }
                                    label: {
                                        Image(systemName: "chevron.forward")
                                            .font(.title3)
                                    }
                                    .tint(.secondary)
                                    .rotationEffect(self.showRequests ? .degrees(90) : .zero)
                                }
                                .padding([.leading, .trailing, .bottom], width * 0.05)
                            })
                            
                        }
                        if self.searchKey.isEmpty && !self.chatViewModel.friends.isEmpty {
                            Section( content: {
                                if self.showFriends {
                                    ForEach(chatViewModel.friends.indices, id: \.self) { index in
                                        FriendRowView(
                                            friend: $chatViewModel.friends[index],
                                            width: width,
                                            height: height * 0.1
                                        )
                                        .padding([.leading, .trailing])
                                        
                                        if (index != chatViewModel.friends.count - 1) {
                                            Divider()
                                                .foregroundStyle(.primary)
                                                .padding([.leading, .trailing])
                                        }
                                    }
                                }
                            }, header: {
                                HStack {
                                    Text("Friends")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.smooth) {
                                            self.showFriends.toggle()
                                        }
                                    }
                                    label: {
                                        Image(systemName: "chevron.forward")
                                            .font(.title3)
                                    }
                                    .tint(.secondary)
                                    .rotationEffect(self.showFriends ? .degrees(90) : .zero)
                                }
                                .padding([.leading, .trailing, .bottom], width * 0.05)
                            })
                            
                        }
                    }
                    .listRowSpacing(height * 0.05)
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
                    
                }

                .navigationDestination(isPresented: $chatViewModel.showProfile, destination: {
                    ProfileView(friend: $chatViewModel.friendInView)
                        .onDisappear {
                            let exitFriend = self.chatViewModel.friendInView
                            if chatViewModel.removalQueue.contains(exitFriend) {
                                chatViewModel.removeFriendFromLocal(exitFriend)
                            }
                            self.chatViewModel.friendInView = Friend()
                        }
                })
            }
    
            .tint(.primary)

        }

    }
}

#Preview {
    FriendsView()
        .environmentObject(ChatViewModel())

}
