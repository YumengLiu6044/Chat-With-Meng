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
    @State var showRequests: Bool = true

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
                                
                                if (friend.id != chatViewModel.friendSearchResult.last?.id) {
                                    Divider()
                                        .padding([.leading, .trailing])
                                }
                            }

                        }
                        if !self.chatViewModel.friendRequests.isEmpty {
                            Section( content: {
                                if self.showRequests {
                                    ForEach (
                                        chatViewModel.friendRequests, id: \.self
                                    ) {
                                        request in
                                        FriendRequestView(
                                            friend: request,
                                            width: width,
                                            height: height * 0.1
                                        )
                                        .onReject {
                                            guard let reject_id = request.id else {
                                                return
                                            }
                                            
                                            self.chatViewModel.removeFriendRequest(at: reject_id)
                                        }
                                        
                                        .onAccept {
                                            guard let requestID = request.id else {
                                                return
                                            }
                                            self.chatViewModel.addFriendFromRequest(of: requestID)
                                        }
                                        .padding([.leading, .trailing])
                                        
                                        if (request.id != chatViewModel.friendRequests.last?.id) {
                                            Divider()
                                                .padding([.leading, .trailing])
                                        }
                                    }
                                }
                            }, header: {
                                HStack {
                                    Text("Requests")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    IconView(iconName: self.showRequests ? "chevron.down" : "chevron.forward", size: height * 0.02, color: .secondary) {
                                        withAnimation(.smooth) {
                                            self.showRequests.toggle()
                                        }
                                    }
                                    .contentTransition(.symbolEffect(.replace))
                                }
                                .padding([.leading, .trailing], width * 0.07)
                            })
                            
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
                .onChange(of: chatViewModel.currentUser.friendRequests) {
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
