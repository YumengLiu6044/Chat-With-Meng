//
//  SettingsView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    @State private var isForgotPassword: Bool = false
    
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
                            Button {
                                chatViewModel.showImagePicker.toggle()
                            } label: {
                                ZStack {
                                    ProfilePicView(
                                        imageURL:
                                            chatViewModel.currentUser.profilePicURL.absoluteString,
                                        imageOverlayData: chatViewModel.currentUser.profileOverlayData,
                                        width: width * 0.3, height: width * 0.3,
                                        isOnline: .constant(true),
                                        isLoading: .constant(true)
                                    )
                                    .shadow(radius: 5)
                                    .padding([.top, .leading], width * 0.1)
                                    

                                    Image(systemName: "pencil")
                                        .font(.largeTitle)
                                        .tint(.primary)
                                        .background {
                                            Circle()
                                                .frame(
                                                    width: width * 0.12,
                                                    height: width * 0.12
                                                )
                                                .foregroundStyle(.background)

                                        }
                                        .shadow(radius: 5)
                                        .offset(x: width * 0.2, y: width * 0.17)

                                }

                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text(chatViewModel.currentUser.userName)
                                    .font(.system(size: width * 0.12))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                    .fontWeight(.bold)
                                    .padding([.bottom, .trailing], height * 0.01)

                                Text(chatViewModel.currentUser.email)
                                    .font(.system(size: width * 0.05))
                                    .tint(.primary)
                                    .padding([.top, .trailing], height * 0.01)
                            }
                            .padding()
                            
                        }

                        List {
                                Section(header: Text("Account")) {
                                    SettingOptionView(header: "User name") {
                                        Text(chatViewModel.currentUser.userName)
                                            
                                    }
                                    SettingOptionView(header: "Forgot Password") {
                                        Button {
                                            isForgotPassword.toggle()
                                        } label: {
                                            Image(systemName: "chevron.right")
                                        }
                                        .tint(.secondary)
                                    }
                                }

                                Section(header: Text("Notifications")) {
                                    SettingOptionView(header: "Human") {
                                        Toggle("", isOn: $chatViewModel.currentUser.humanNotifications)
                                    }
                                    SettingOptionView(header: "AI") {
                                        Toggle("", isOn: $chatViewModel.currentUser.AiNotifications)
                                    }

                                }
                        }
                        .scrollContentBackground(.hidden)
                        .padding([.top], height * 0.05)
                        
                        Button {
                            appViewModel.signOut()
                            appViewModel.switchTo(view: .login)
                        }
                        label: {
                            HStack {
                                Spacer()
                                Text("Sign out")
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
                    .onChange(of: chatViewModel.currentUser) {
                        chatViewModel.updateCurrentUser()
                        print("Updated")
                    }
                    .onChange(of: chatViewModel.profilePic) {
                        FirebaseManager.uploadProfilePic(profilePic: chatViewModel.profilePic!) {
                            imgURL, colorData in
                            
                            if let imgURL = imgURL, let colorData = colorData {
                                chatViewModel.currentUser.profilePicURL = imgURL
                                chatViewModel.currentUser.profileOverlayData = colorData
                            }
                        }
                    }
                    .onAppear {
                        width = geometry.size.width
                        height = geometry.size.height
                    }
                }
            
            
        }
        .fullScreenCover(isPresented: $isForgotPassword, onDismiss: nil) {
            PasswordResetView(isForgetPassword: $isForgotPassword, width: width, height: height)
        }
        .fullScreenCover(isPresented: $chatViewModel.showImagePicker, onDismiss: nil) {
            ImagePicker(image: $chatViewModel.profilePic)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
        .environmentObject(ChatViewModel())
        .preferredColorScheme(.dark)
}
