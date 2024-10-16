//
//  FriendSearchResult.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/15/24.
//

import SwiftUI

struct FriendSearchResult: View {
    var user: User
    
    var width: CGFloat  = 300
    var height: CGFloat = 80
    
    @State var isLoading: Bool = true
    var body: some View {
        HStack {
            ProfilePicView(imageURL: user.profilePicURL.absoluteString, imageOverlayData: user.profileOverlayData, width: width * 0.15, height: width * 0.15, isOnline: .constant(true), isLoading: $isLoading)
                .padding()
            
            Text(user.userName)
                .font(.system(size: height * 0.4))
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
            
            Spacer()
            
            IconView(iconName: "plus") {
                print("Add friend")
            }
            
            
        }
    }
}

#Preview {
    FriendSearchResult(user: User())
}
