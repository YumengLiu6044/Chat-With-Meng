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
    var size: CGFloat = 32
    var color: Color = .primary
    
    
    var action: (() -> Void)?
    var body: some View {
        Button {
            self.action?()
        } label: {
            ZStack {
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
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
                        
                        .padding([.leading, .bottom], size * 1.65)
                    
                }
            }
        }
        .tint(self.color)
        .buttonStyle(.borderless)
        
    }
}

#Preview {
    IconView(iconName: "paperplane", count: 8) {
        print("Sent")
    }
}
