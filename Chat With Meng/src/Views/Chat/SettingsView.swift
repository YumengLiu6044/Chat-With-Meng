//
//  SettingsView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var settingVM: SettingViewModel
    
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    @State private var isForgotPassword: Bool = false
    @State private var userName: String = ""
    
    var body: some View {
        GeometryReader {
            geometry in
            ZStack {
                Rectangle()
                    .frame(width: width, height: height * 0.2)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .foregroundStyle(
                        .linearGradient(
                            Gradient(colors: [.myPurple, .myBlue]),
                            startPoint: .leading, endPoint: .trailing)
                    )
                
                    .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Button {
                                settingVM.showImagePicker.toggle()
                            } label: {
                                ZStack {
                                    ProfilePicView(
                                        imageURL: settingVM.currentUser.profilePicURL,
                                        imageOverlayData: settingVM.currentUser.profileOverlayData,
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
                                Text(settingVM.currentUser.userName)
                                    .font(.system(size: width * 0.12))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                    .fontWeight(.bold)
                                    .padding([.bottom, .trailing], height * 0.01)

                                Text(settingVM.currentUser.email)
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
                                            .submitLabel(.done)
                                            .onSubmit {
                                                settingVM.updateUserName(to: self.userName) {
                                                    error in
                                                    if let error = error {
                                                        self.settingVM.toast = Toast(style: .error, message: error.localizedDescription)
                                                        self.userName = self.settingVM.currentUser.userName
                                                    }
                                                    else {
                                                        self.settingVM.toast = Toast(style: .success, message: "User name changed")
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
                                            
                                            Toggle("", isOn: $settingVM.currentUser.humanNotifications)
                                                .onTapGesture {
                                                    settingVM.currentUser.humanNotifications.toggle()
                                                    self.settingVM.updateCurrentUserByKeyVal(key: User.keys.humanNotifications, val: self.settingVM.currentUser.humanNotifications)
                                                }
                                                
                                            
                                        }
                                        SettingOptionView(header: "AI") {
                                            Toggle("", isOn: $settingVM.currentUser.AiNotifications)
                                                .onTapGesture {
                                                    settingVM.currentUser.AiNotifications.toggle()
                                                    self.settingVM.updateCurrentUserByKeyVal(key: User.keys.AiNotifications, val: self.settingVM.currentUser.AiNotifications)
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
                                    self.appViewModel.switchTo(view: .login)
                                }
                                else {
                                    self.settingVM.toast = Toast(style: .error, message: "Failed to sign out")
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
                        .frame(alignment: .bottom)
                    }
                    .onChange(of: settingVM.profilePic) {
                        settingVM.updateProfilePic()
                        
                    }
                    .onAppear {
                        width = geometry.size.width
                        height = geometry.size.height
                        self.userName = settingVM.currentUser.userName
                    }
                }
            .ignoresSafeArea(.keyboard)
            
        }
        
        .fullScreenCover(isPresented: $isForgotPassword, onDismiss: nil) {
            PasswordResetView(isForgetPassword: $isForgotPassword, width: width, height: height, isSelf: true)
        }
        .fullScreenCover(isPresented: $settingVM.showImagePicker, onDismiss: nil) {
            ImagePicker(image: $settingVM.profilePic)
        }
    }
}
