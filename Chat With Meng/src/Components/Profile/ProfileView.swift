//
//  ProfileView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/11/24.
//

import SwiftUI

struct ProfileView: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    var body: some View {
        GeometryReader {
            geometry in
            ZStack {
                VStack {
                    Rectangle()
                        .frame(width: width, height: height * 0.2)
                        .foregroundStyle(
                            .linearGradient(
                                Gradient(colors: [.myPurple, .myBlue]),
                                startPoint: .leading, endPoint: .trailing)
                        )
                        .ignoresSafeArea()

                    Spacer()
                }

                VStack {
                    HStack {
                        ProfilePicView(
                            imageURL:
                                "https://img.decrypt.co/insecure/rs:fit:3840:0:0:0/plain/https://cdn.decrypt.co/wp-content/uploads/2024/05/doge-dogecoin-meme-kabosu-gID_7.jpg@webp",
                            width: width * 0.3, height: width * 0.3,
                            isOnline: .constant(true),
                            isLoading: .constant(true)
                        )
                        
                        .padding([.top, .leading], width * 0.1)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Friend")
                                .font(.system(size: width * 0.12))
                                .fontWeight(.bold)
                                .padding([.bottom, .trailing], height * 0.01)

                            Text("friend@uci.edu")
                                .font(.system(size: width * 0.05))
                                .tint(.primary)
                                .padding([.top, .trailing], height * 0.01)
                        }
                        .padding()

                    }
        
                    List {
                        
                    }
                    .padding([.top], height * 0.05)
                    
                    Spacer()

                }
            }
            .background(
                Color(.init(white: 0, alpha: 0.1))
                    .ignoresSafeArea()
            )
            .onAppear {
                width = geometry.size.width
                height = geometry.size.height
            }

        }
    }
}

#Preview {
    ProfileView()
}
