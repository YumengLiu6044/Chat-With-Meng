//
//  FriendSearchResult.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/15/24.
//

import SwiftUI


struct HorizontalProfileView: View {
    var friend: Friend
    var width: CGFloat  = 300
    var height: CGFloat = 80
    var onAddAction : (() -> Void)?

    var body: some View {
        HStack {
            ProfilePicView(
                imageURL: friend.profilePicURL,
                imageOverlayData: friend.profileOverlayData,
                width: width * 0.15,
                height: width * 0.15
            )
            .padding([.leading, .trailing])
    
            Text(friend.userName)
                .font(.system(size: height * 0.32))
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            IconView(iconName: "plus") {
                self.onAddAction?()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
