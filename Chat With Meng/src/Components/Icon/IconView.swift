//
//  IconView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct IconView: View {
    var iconName: String = "person"
    var count: Int = 0
    var size: CGFloat = 30
    
    
    var action: (() -> Void)?
    var body: some View {
        Button {
            if let action = action {
                action()
            }
        } label: {
            ZStack {
                Image(systemName: iconName)
                    .font(.system(size: size))
                    .fontWeight(.semibold)
                
                if count > 0 {
                    Text(String(min(count, 99)))
                        .font(.system(size: size * 0.6))
                        .foregroundStyle(.white)
                        .background {
                            Circle()
                                .fill(.red)
                                .frame(width: size * 0.7)
                            
                        }
                        .offset(x: size * 0.8, y: size * -0.8)
                }
            }
        }
        .tint(.primary)
    }
}

#Preview {
    IconView(iconName: "paperplane", count: 8) {
        print("Sent")
    }
}
