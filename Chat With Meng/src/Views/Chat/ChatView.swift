//
//  ChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @ObservedObject var chattingViewModel: ChattingViewModel = ChattingViewModel()
    
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    
    var body: some View {
        GeometryReader {
            geometry in 
            NavigationStack {
                VStack {
                    HStack {
                        Text("Chat")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        IconView(iconName: "paperplane") {
                            withAnimation(.smooth) {
                                chattingViewModel.isComposing.toggle()
                            }
                        }
                        
                    }
                    .padding([.top, .leading, .trailing])
                    
                    if chattingViewModel.isComposing {
                        ComposeGroupView(width: width, height: height)
                            .environmentObject(chattingViewModel)
                            .environmentObject(chatViewModel)
                    }
                    else {
                        
                    }
                    Spacer()
                    
                }
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                    
                    print("\((width, height))")
                }
            }
        }
        
    }
}

#Preview {
    ChatView()
}
