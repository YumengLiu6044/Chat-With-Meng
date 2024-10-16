//
//  FriendSearchResult.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/15/24.
//

import SwiftUI

struct FriendRequestView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    var friend: Friend
    
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
//            ProfilePicView(imageURL: friend.profilePicURL, imageOverlayData: friend.profileOverlayData, width: width * 0.15, height: width * 0.15, isOnline: .constant(true), isLoading: $isLoading)
//                .padding()
            
            NavigationLink(destination: ProfileView(friend: self.friend).environmentObject(self.chatViewModel)) {
                ProfilePicView(
                    imageURL: friend.profilePicURL,
                    imageOverlayData: friend.profileOverlayData,
                    width: width * 0.15,
                    height: width * 0.15
                )
                    .padding()
            }
            .tint(.none)
            
            Text(friend.userName)
                .font(.system(size: height * 0.4))
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
            
            Spacer()
            
            IconView(iconName: "checkmark", color: .blue) {
                print("Accept")
            }
            
            
        }
        
    }
}

#Preview {
    FriendRequestView(friend: Friend())
        .environmentObject(ChatViewModel())
}
