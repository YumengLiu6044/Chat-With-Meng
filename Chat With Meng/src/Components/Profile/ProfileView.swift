//
//  ProfileView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/11/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @Binding var friend: Friend
    var rowState: FriendRowState
    
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
                                friend.profilePicURL,
                            imageOverlayData: friend.profileOverlayData,
                            width: width * 0.3,
                            height: width * 0.3
                        )
                        .shadow(radius: 5)
                        .padding([.leading], width * 0.1)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(friend.userName)
                                .font(.system(size: width * 0.12))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .fontWeight(.bold)
                                .padding([.bottom, .trailing], height * 0.01)

                            Text(friend.email)
                                .font(.system(size: width * 0.05))
                                .tint(.primary)
                                .padding([.top, .trailing], height * 0.01)
                        }
                        .padding()

                    }
        
                    List {
                        
                    }
                    .scrollContentBackground(.hidden)
                    .padding([.top], height * 0.05)
                    
                    Button {
                        if self.rowState == .friended {
                            self.chatViewModel.updateFriendByKeyVal(for: self.friend.userID, FriendRef.keys.notifications, !self.friend.notifications) {
                                self.friend.notifications.toggle()
                            }
                        }
                    }
                    label: {
                        HStack {
                            Spacer()
                            Text("Unfriend")
                                .font(.title2)
                            Spacer()
                            
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: width * 0.03))
                    .tint(.red)
                    .shadow(radius: 5)
                    .padding([.bottom], height * 0.13)
                    .padding([.leading, .trailing])
                    
                    
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
                
                withAnimation {
                    self.chatViewModel.showMenu = false
                }
            }
            .onDisappear {
                withAnimation {
                    self.chatViewModel.showMenu = true
                }
            }

        }
    }
}

#Preview {
    ProfileView(friend: .constant(Friend()), rowState: .friended)
        .environmentObject(ChatViewModel())
}
