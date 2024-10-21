//
//  ChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct ChatView: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    
    var body: some View {
        GeometryReader {
            geometry in 
            VStack {
                HStack {
                    
                    Text("Chat")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    IconView(iconName: "paperplane") {
                        print("Sent")
                    }
                    
                    
                }
                .padding()
                Spacer()
                
            }
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
            }
        }
        
    }
}

#Preview {
    ChatView()
}
