//
//  FriendSearchResult.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/15/24.
//

import SwiftUI

enum FriendRowState: String {
    case requested, friended, searched
}

struct FriendRowView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @Binding var friend: Friend
    
    var width: CGFloat  = 300
    var height: CGFloat = 80
    
    @State private var resultState: FriendRowState = .searched
    

    var body: some View {
        HStack {
            NavigationLink(destination: ProfileView(friend: self.friend).environmentObject(self.chatViewModel)) {
                ProfilePicView(
                    imageURL: friend.profilePicURL,
                    imageOverlayData: friend.profileOverlayData,
                    width: width * 0.15,
                    height: width * 0.15
                )
                .padding(.leading)
            }
    
            Text(friend.userName)
                .font(.system(size: height * 0.4))
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
            
            Spacer()
            
            switch self.resultState {
            case .requested:
                IconView(iconName: "checkmark", size: 30, color: .blue) {
                    Task {
                        await self.chatViewModel.addFriend(from: friend.userID)
                    }
                }
                .padding(.trailing)
                
                IconView(iconName: "xmark", size: 30, color: .red) {
                    let reject_id = friend.userID
                    Task {
                        await self.chatViewModel.removeFriendRequest(at: reject_id)
                    }
                }
                
                
            case .friended:
                IconView(iconName: "paperplane") {
                    print("Message")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing)
                
                IconView(iconName: friend.notifications ? "bell" : "bell.slash") {
                    self.chatViewModel.updateFriendByKeyVal(for: self.friend.userID, FriendRef.keys.notifications, !self.friend.notifications) {
                        self.friend.notifications.toggle()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .contentTransition(.symbolEffect(.replace))
            
            case .searched:
                IconView(iconName: "plus") {
                    Task {
                        chatViewModel.sendFriendRequest(to: friend.userID)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            if self.chatViewModel.friendRequests.contains(self.friend) {
                self.resultState = .requested
            }
            else if self.chatViewModel.friends.contains(self.friend) {
                self.resultState = .friended
            }
            else {
                self.resultState = .searched
            }
        }
    }
}

#Preview {
    FriendRowView(friend: .constant(Friend()))
        .environmentObject(ChatViewModel())
}
