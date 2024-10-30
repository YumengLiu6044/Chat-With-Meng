//
//  FriendSearchResult.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/15/24.
//

import SwiftUI


struct FriendRowView: View {
    @EnvironmentObject var friendVM: FriendsViewModel
    @Binding var friend: Friend
    
    var width: CGFloat  = 300
    var height: CGFloat = 80
    
    var resultState: FriendRowState
    
    var body: some View {
        HStack {
            NavigationLink(value: friend) {
                ProfilePicView(
                    imageURL: friend.profilePicURL,
                    imageOverlayData: friend.profileOverlayData,
                    width: width * 0.15,
                    height: width * 0.15
                )
                .onTapGesture {
                    self.friendVM.friendInView = friend
                    self.friendVM.showProfile  = true
                    self.friendVM.rowState     = self.resultState
                }
                .padding([.leading, .trailing])
            }
    
            Text(friend.userName)
                .font(.system(size: height * 0.32))
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            switch self.resultState {
            case .requested:
                IconView(iconName: "checkmark", size: 30, color: .blue) {
                    Task {
                        await self.friendVM.addFriend(from: friend.userID)
                    }
                }
                .padding(.trailing)
                
                IconView(iconName: "xmark", size: 30, color: .red) {
                    let reject_id = friend.userID
                    Task {
                        await self.friendVM.removeFriendRequest(at: reject_id)
                    }
                }
                
                
            case .friended:
                IconView(iconName: "paperplane") {
                    print("Message")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing)
                
                IconView(iconName: friend.notifications ? "bell" : "bell.slash") {
                    self.friendVM.updateFriendByKeyVal(for: self.friend.userID, FriendRef.keys.notifications, !self.friend.notifications)
                }
                .buttonStyle(PlainButtonStyle())
                .contentTransition(.symbolEffect(.replace))
            
            case .searched:
                IconView(iconName: "plus") {
                    Task {
                        friendVM.sendFriendRequest(to: friend.userID)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
