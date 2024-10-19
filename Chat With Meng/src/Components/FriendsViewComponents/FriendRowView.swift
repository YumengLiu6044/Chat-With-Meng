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
    var friend: Friend
    
    var width: CGFloat  = 300
    var height: CGFloat = 80
    
    @State private var resultState: FriendRowState = .searched
    
    var onRejectAction: (() -> Void)?
    var onAcceptAction: (() -> Void)?
    var onMessageAction: (() -> Void)?
    
    init(friend: Friend, width: CGFloat = 300, height: CGFloat = 80) {
        self.friend = friend
        self.width = width
        self.height = height
        
    }
    var body: some View {
        HStack {
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
            
            switch self.resultState {
            case .requested:
                IconView(iconName: "checkmark", color: .blue) {
                    self.onAcceptAction?()
                }
                
                IconView(iconName: "xmark", color: .red) {
                    self.onRejectAction?()
                }
                .padding([.trailing])
                
            case .friended:
                IconView(iconName: "paperplane") {
                    print("Message")
                }
                .buttonStyle(PlainButtonStyle())
            
            case .searched:
                IconView(iconName: "plus") {
                    Task {
                        chatViewModel.sendFriendRequest(to: friend.id)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            if self.chatViewModel.friendRequests
                .filter({$0.id == self.friend.id}).count > 0 {
                self.resultState = .requested
            }
            else if self.chatViewModel.friends
                .filter({$0.id == self.friend.id }).count > 0 {
                self.resultState = .friended
            }
            else {
                self.resultState = .searched
            }
        }
    }
}

extension FriendRowView {
    func onAccept(_ action: @escaping () -> Void) -> FriendRowView {
        var view = self
        view.onAcceptAction = action
        return view
    }
    
    func onReject(_ action: @escaping () -> Void) -> FriendRowView {
        var view = self
        view.onRejectAction = action
        return view
    }
    
    func onMessage(_ action: @escaping () -> Void) -> FriendRowView {
        var view = self
        view.onMessageAction = action
        return view
    }
}

#Preview {
    FriendRowView(friend: Friend())
        .environmentObject(ChatViewModel())
}
