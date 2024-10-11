//
//  SettingOptionView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/11/24.
//

import SwiftUI

struct SettingOptionView<Content: View>: View {
    var header: String = "Option"
    var content: (() -> Content)?
    
    var body: some View {
        HStack {
            Text(header)
            
            Spacer()
            
            if let content = content {
                content()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingOptionView(header: "User name") {
        Text("Yumeng")
    }
}
