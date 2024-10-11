//
//  FriendsView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct FriendsView: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    
    var body: some View {
        GeometryReader {
            geometry in
            VStack {
                HStack {
                    
                    Text("Friends")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    IconView(iconName: "person.2") {
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
    FriendsView()
}
