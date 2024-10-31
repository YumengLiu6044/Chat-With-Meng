//
//  MessageLogsSectionView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/30/24.
//

import SwiftUI

struct MessageLogsSectionView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ScrollView{
            VStack(spacing: height * 0.01) {
                ForEach(chattingVM.chatMap) {chat in
                    ChatRowView(chatMapItem: chat, width: width, height: height * 0.1)
                        .environmentObject(chattingVM)
                        .padding([.leading, .trailing])
                        .padding(.top, chat == chattingVM.chatMap.first ? 5 : 0)
                        .scrollTransition {
                            content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                        }
                    
                    if (chat != chattingVM.chatMap.last) {
                        Divider()
                            .foregroundStyle(.primary)
                            .padding([.leading, .trailing])
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top) {
            SearchBar(text: .constant(""))
        }
    }
}

#Preview {
    MessageLogsSectionView(width: 300, height: 700)
        .environmentObject(ChattingViewModel())
}
