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
        List {
            ForEach(chattingVM.chatMap) {chat in
                ChatRowView(
                    chatMapItem: chat,
                    width: width,
                    height: height * 0.1
                )
                    .environmentObject(chattingVM)
            }
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .safeAreaInset(edge: .top) {
            SearchBar(text: .constant(""))
        }
    }
}

#Preview {
    MessageLogsSectionView(width: 300, height: 700)
        .environmentObject(ChattingViewModel())
}
