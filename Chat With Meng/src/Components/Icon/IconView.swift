//
//  IconView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct IconView: View {
    var iconName: String = "person"
    var action: (() -> Void)?
    var body: some View {
        Button {
            if let action = action {
                action()
            }
        } label: {
            Image(systemName: iconName)
                .font(.title)
                .fontWeight(.semibold)
        }
        .tint(.primary)
    }
}

#Preview {
    IconView(iconName: "paperplane") {
        print("Sent")
    }
}
