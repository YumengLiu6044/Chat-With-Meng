//
//  MessageView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/31/24.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        let chatInView = chattingVM.chatObjInView
        
        VStack {
            
        }
        .safeAreaInset(edge: .top) {
            HStack {
                ProfilePicView(
                    imageURL: chatInView.chatCoverURL,
                    imageOverlayData: chatInView.chatCoverOverlay,
                    width: width * 0.11,
                    height: width * 0.11
                )
                // .padding(.leading, width * 0.12)
                
                Text(chatInView.chatTitle)
                    .font(.title)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.leading)
                    // .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)
            .background {
                Rectangle()
                    .fill()
                    .foregroundStyle(.ultraThickMaterial)
                    .frame(width: width)
                    .ignoresSafeArea()
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, height * -0.055)
        }
        .toolbarRole(.editor)
    }
}

#Preview {
    MessageView(width: 400, height: 700)
        .environmentObject(ChattingViewModel())
}
