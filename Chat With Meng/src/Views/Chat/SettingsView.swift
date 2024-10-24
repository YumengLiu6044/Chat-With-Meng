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
    @State private var userName: String = ""
    
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
                                            chatViewModel.currentUser.profilePicURL,
                                        imageOverlayData: chatViewModel.currentUser.profileOverlayData,
                                        width: width * 0.3, height: width * 0.3
                                        
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
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                    .padding([.top, .trailing], height * 0.01)
                            }
                            .padding()
                            
                        }

                        List {
                            Section(
                                    content: {
                                    SettingOptionView(header: "User name") {
                                        TextField("", text: self.$userName)
                                            .multilineTextAlignment(.trailing)
                                            .onSubmit {
                                                chatViewModel.updateUserName(to: self.userName) {
                                                    error in
                                                    if let error = error {
                                                        self.chatViewModel.toast = Toast(style: .error, message: error.localizedDescription)
                                                        self.userName = self.chatViewModel.currentUser.userName
                                                    }
                                                    else {
                                                        self.chatViewModel.toast = Toast(style: .success, message: "User name changed")
                                                    }
                                                }
                                            }
                                            
                                                
                                        }
                                        SettingOptionView(header: "Forgot Password") {
                                            Button {
                                                isForgotPassword.toggle()
                                                
                                            } label: {
                                                Image(systemName: "chevron.right")
                                            }
                                            .tint(.secondary)
                                        }
                                    },
                                    header: {
                                        HStack {
                                            IconView(iconName: "person.fill", size: height * 0.024, color: .secondary)
                                                
                                            Text("Account")
                                                .fontWeight(.medium)
                                                
                                        }
                                    })
                                
                                Section(
                                    content: {
                                        SettingOptionView(header: "Human") {
                                            Toggle("", isOn: $chatViewModel.currentUser.humanNotifications)
                                                .onTapGesture {
                                                    chatViewModel.currentUser.humanNotifications.toggle()
                                                    self.chatViewModel.updateCurrentUserByKeyVal(key: User.keys.humanNotifications, val: self.chatViewModel.currentUser.humanNotifications)
                                                }
                                                
                                            
                                        }
                                        SettingOptionView(header: "AI") {
                                            Toggle("", isOn: $chatViewModel.currentUser.AiNotifications)
                                                .onTapGesture {
                                                    chatViewModel.currentUser.AiNotifications.toggle()
                                                    self.chatViewModel.updateCurrentUserByKeyVal(key: User.keys.AiNotifications, val: self.chatViewModel.currentUser.AiNotifications)
                                                }
                                                
                                        }
                                    },
                                    header: {
                                        HStack {
                                            IconView(iconName: "bell.fill", size: height * 0.024, color: .secondary)
                                                
                                            Text("Notifications")
                                                .fontWeight(.medium)
                                                
                                        }
                                    })
                        }
                        .scrollContentBackground(.hidden)
                        .padding([.top], height * 0.05)
                        
                        Button {
                            appViewModel.signOut {
                                success in
                                if success {
                                    self.chatViewModel.deinitializeCurrentUser()
                                    self.appViewModel.switchTo(view: .login)
                                }
                                else {
                                    self.chatViewModel.toast = Toast(style: .error, message: "Failed to sign out")
                                }
                                
                            }
                            
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
                    .onChange(of: chatViewModel.profilePic) {
                        chatViewModel.updateProfilePic()
                        
                    }
                    .onAppear {
                        width = geometry.size.width
                        height = geometry.size.height
                        
                        self.userName = chatViewModel.currentUser.userName
                    }
                }
            .ignoresSafeArea(.keyboard)
            
        }
        
        .fullScreenCover(isPresented: $isForgotPassword, onDismiss: nil) {
            PasswordResetView(isForgetPassword: $isForgotPassword, width: width, height: height, isSelf: true)
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
