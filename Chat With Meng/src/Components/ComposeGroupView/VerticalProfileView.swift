//
//  VerticalProfileView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/25/24.
//

import SwiftUI

struct VerticalProfileView: View {
    var friend: Friend
    var size: CGFloat = 50
    
    var body: some View {
        ProfilePicView(
            imageURL: friend.profilePicURL,
            imageOverlayData: friend.profileOverlayData,
            width: size,
            height: size
        )
    }
}


#Preview {
    VerticalProfileView(friend: Friend())
}
