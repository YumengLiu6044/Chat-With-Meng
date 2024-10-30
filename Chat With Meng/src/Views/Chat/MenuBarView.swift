//
//  MenuBarView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct MenuBarView: View {
    @Namespace private var selectionAnimation
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    
    var width: CGFloat = 300
    var height: CGFloat = 60
    
    @ViewBuilder func selection() -> some View {
        Circle()
            .frame(width: height * 0.9, height: height * 0.9)
            .foregroundStyle(.ultraThinMaterial)
            .shadow(radius: height * 0.1)
            .matchedGeometryEffect(id: "selectedSegmentHighlight", in: self.selectionAnimation)
    }
    
    var body: some View {
        HStack {
            IconView(iconName: "message", count: 5, size: 35) {
                chatViewModel.switchTo(view: .messages)
            }
            .frame(width: self.width * 0.2)
            .background {
                if (chatViewModel.chatViewSelection == .messages) {
                    selection()
                }
            }
            Spacer()
            
            IconView(iconName: "person.2", count: self.friendVM.friendRequests.count, size: 35) {
                chatViewModel.switchTo(view: .friends)
            }
            .frame(width: self.width * 0.2)
            .background {
                if (chatViewModel.chatViewSelection == .friends) {
                    selection()
                }
            }
            Spacer()
            
            IconView(iconName: "gear", size: 35) {
                chatViewModel.switchTo(view: .settings)
            }
            .frame(width: self.width * 0.2)
            .background {
                if (chatViewModel.chatViewSelection == .settings) {
                    selection()
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: height * 0.5)
                .foregroundStyle(.ultraThickMaterial)
                .frame(width: width, height: height)
                .shadow(radius: height * 0.1)
            
        }
        .frame(width: width, height: height)
        .transition(.opacity)
        
    }
}
