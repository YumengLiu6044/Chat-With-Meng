//
//  FriendsView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct FriendsView: View {

    @EnvironmentObject var chatViewModel: ChatViewModel

    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    @State private var searchKey: String = ""

    var body: some View {
        GeometryReader {
            geometry in
            VStack {
                HStack {

                    Text("Friends")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    IconView(iconName: "person.badge.plus", count: 2) {
                        print("Sent")
                    }
                    .padding()

                }
                .padding([.top, .leading, .trailing])
                
                SearchBar(text: $searchKey)
                    .padding([.leading, .trailing], width * 0.02)
                    .padding([.top], height * -0.04)
                .onChange(of: searchKey) {
                    Task {
                        await self.chatViewModel.searchUsers(from: searchKey)
                    }
                }
                
                if (!searchKey.isEmpty) {
                    List {
                        ForEach(chatViewModel.userSearchResult) {
                            user in
                            FriendSearchResult(user: user, width: width * 1.0, height: height * 0.1)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }

                Spacer()

            }
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
            }

        }

    }
}

#Preview {
    FriendsView()
        .environmentObject(ChatViewModel())

}
