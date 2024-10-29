//
//  VerticalProfileView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/25/24.
//

import SwiftUI

struct VerticalProfileView: View {
    var friend: Friend
    var width: CGFloat = 80
    var height: CGFloat = 100
    var onTapAction: (() -> Void)?
    
    var body: some View {
        Button {
            self.onTapAction?()
        }
        label:{
            ZStack {
                ProfilePicView(
                    imageURL: friend.profilePicURL,
                    imageOverlayData: friend.profileOverlayData,
                    width: width * 0.8,
                    height: width * 0.8
                )
                
                Image(systemName: "minus.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .foregroundStyle(.red)
            }
        }
        .frame(width: width, height: height)
    }
}


#Preview {
    VerticalProfileView(friend: Friend())
        .preferredColorScheme(.dark)
}
