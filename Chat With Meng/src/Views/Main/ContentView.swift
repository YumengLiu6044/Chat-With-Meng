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
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))

        case .chat:
            ChatViewMain()
                .environmentObject(appViewModel)
                .transition(.move(edge: .top))
        }
    }
        
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
