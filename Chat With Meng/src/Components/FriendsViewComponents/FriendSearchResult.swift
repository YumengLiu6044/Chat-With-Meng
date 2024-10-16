//
//  FriendSearchResult.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/15/24.
//

import SwiftUI

struct FriendSearchResult: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    var friend: Friend
    @State private var isFriend: Bool = false
    
    var width: CGFloat  = 300
    var height: CGFloat = 80
    
    @State var isLoading: Bool = true
    
    init(friend: Friend, width: CGFloat = 300, height: CGFloat = 80) {
        self.friend = friend
        self.width = width
        self.height = height
        
    }
    var body: some View {
        HStack {
            ProfilePicView(imageURL: friend.profilePicURL, imageOverlayData: friend.profileOverlayData, width: width * 0.15, height: width * 0.15, isOnline: .constant(true), isLoading: $isLoading)
                .padding()
            
            Text(friend.userName)
                .font(.system(size: height * 0.4))
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
            
            Spacer()
            
            if !self.isFriend {
                IconView(iconName: "plus") {
                    Task {
                        chatViewModel.sendFriendRequenst(to: friend.id)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            else {
                IconView(iconName: "paperplane") {
                    Task {
                        chatViewModel.sendFriendRequenst(to: friend.id)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            self.isFriend = chatViewModel.currentUser.friends.contains(friend)
        }
        
    }
}

#Preview {
    FriendSearchResult(friend: Friend())
        .environmentObject(ChatViewModel())
}
