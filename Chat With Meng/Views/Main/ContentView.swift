//
//  ContentView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 7/11/24.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var appViewModel: AppViewModel = AppViewModel()

    var body: some View {
        switch appViewModel.currentView {
        case .login:
            LoginView()
                .environmentObject(appViewModel)
                .onAppear {
                    appViewModel.switchTo(view: .chat, animationLength: 1)
                }

        case .chat:
            ChatView()
                .transition(.move(edge: .bottom))
                

        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
