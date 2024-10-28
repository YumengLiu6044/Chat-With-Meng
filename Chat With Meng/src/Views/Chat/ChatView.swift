//
//  ChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    @State private var isComposing: Bool = false
    @State private var searchkey: String = ""

    
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
                                self.isComposing.toggle()
                            }
                            print(self.isComposing)
                        }
                        
                        
                    }
                    .padding([.top, .leading, .trailing])
                    
                    if isComposing {
                        SearchBar(
                            text: $searchkey,
                            onCancelAction: {
                                self.searchkey = ""
                                withAnimation(.smooth) {
                                    self.isComposing = false
                                }
                            },
                            onSearchAction: {
                                
                            }
                        )
                        .padding([.leading, .trailing], width * 0.02)
                        .padding([.top], height * -0.02)
                    }
                    else {
                        
                    }
                    Spacer()
                    
                }
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                }
            }
        }
        
    }
}

#Preview {
    ChatView()
}
