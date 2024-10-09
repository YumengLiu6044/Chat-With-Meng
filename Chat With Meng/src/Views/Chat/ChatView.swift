//
//  ChatView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/5/24.
//

import SwiftUI

struct ChatView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var width:               CGFloat     =   100
    @State private var height:              CGFloat     =   100
    
   
    var body: some View {
        GeometryReader {
            geometry in
            
            NavigationStack {
                VStack {
                    
                }
                .toolbar {
                    Button {
                        appViewModel.switchTo(view: .login)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                    }
                    
                }
                .navigationTitle(
                    Text("Chat")
                        .font(.caption)
                        .fontWeight(.bold)
                )
                
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
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
