//
//  MessageLogsSectionView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/30/24.
//

import SwiftUI

struct MessageLogsSectionView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    
    var body: some View {
        ScrollView{
            VStack {
                ForEach(chattingVM.chatMap) {chat in
                    Text(chat.chatID)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            SearchBar(text: .constant(""))
        }
        
    }
}

#Preview {
    MessageLogsSectionView()
        .environmentObject(ChattingViewModel())
}
