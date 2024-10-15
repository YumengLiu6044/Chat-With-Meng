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
            NavigationStack {
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
                    .searchable(text: $searchKey)
                    .onChange(of: searchKey) {
                        Task {
                            await self.chatViewModel.searchUsers(from: searchKey)
                        }
                    }
                    .searchSuggestions({
                        List {
                            ForEach (chatViewModel.userSearchResult) {
                                result in
                                Text(result.userName)
                            }
                        }
                    })
                    .padding()
                    
                    Spacer()
                    
                }
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                }
            }
        }
        
        
    }
}

#Preview {
    FriendsView()
        .environmentObject(ChatViewModel())
        
}
