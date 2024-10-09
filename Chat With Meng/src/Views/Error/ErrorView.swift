//
//  ErrorView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/8/24.
//

import SwiftUI

struct ErrorView: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    var body: some View {
        GeometryReader {
            geometry in
            VStack(alignment: .leading) {
                Spacer()
                Text("Something is preventing you from chatting with Meng")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
                    
                
                HStack {
                    Spacer()
                    
                    Image(systemName: "questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.5, height: width * 0.5)
                        .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                Text("Contact developer: yumel13@uci.edu")
                    .padding()
            }
            .padding()
            .background(Color(.init(white: 0, alpha: 0.15)).ignoresSafeArea(.all))
            .onAppear {
                width   =   geometry.size.width
                height  =   geometry.size.height
            }
            
        }
        
    }
}

#Preview {
    ErrorView()
        .preferredColorScheme(.dark)
}
