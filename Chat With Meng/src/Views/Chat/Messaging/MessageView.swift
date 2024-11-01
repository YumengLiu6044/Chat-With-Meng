//
//  MessageView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/31/24.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var chattingVM: ChattingViewModel
    
    var body: some View {
        let chatInView = chattingVM.chatObjInView
        
        NavigationStack {
            VStack {
                
            }
            .navigationTitle(chatInView.chatTitle)
        }
    }
}

#Preview {
    MessageView()
        .environmentObject(ChattingViewModel())
}
