//
//  SettingsView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    @AppStorage("saved_email") var savedEmail: String = ""
    @AppStorage("saved_password") var savedPassword: String = ""
    
    var body: some View {
        GeometryReader {
            geometry in
            NavigationView {
                ZStack {
                    VStack {
                        Rectangle()
                            .frame(width: width, height: height * 0.2)
                            .foregroundStyle(
                                .linearGradient(
                                    Gradient(colors: [.pink, .blue]),
                                    startPoint: .leading, endPoint: .trailing)
                            )
                            .ignoresSafeArea()
                        
                        Spacer()
                    }

                    
                    VStack {
                        HStack {
                            Button {
                                print("Changing profile pic")
                            } label: {
                                ZStack {
                                    ProfilePicView(
                                        imageURL:
                                            "https://img.decrypt.co/insecure/rs:fit:3840:0:0:0/plain/https://cdn.decrypt.co/wp-content/uploads/2024/05/doge-dogecoin-meme-kabosu-gID_7.jpg@webp",
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
                                Text("Yumeng")
                                    .font(.system(size: width * 0.12))
                                    .fontWeight(.bold)
                                    .padding([.bottom, .trailing], height * 0.01)

                                Text("yumel13@uci.edu")
                                    .font(.system(size: width * 0.05))
                                    .tint(.primary)
                                    .padding([.top, .trailing], height * 0.01)
                            }
                            .padding()
                            
                        }

                        List {
                                Section(header: Text("Account")) {
                                    SettingOptionView(header: "User name") {
                                        Text("Yumeng")
                                    }
                                    SettingOptionView(header: "Online Status") {
                                        Toggle("", isOn: .constant(true))
                                    }
                                    SettingOptionView(header: "Forgot Password") {
                                        NavigationLink("", destination: PasswordResetView(isForgetPassword: .constant(true), width: width, height: height))
                                    }
                                }

                                Section(header: Text("Notifications")) {
                                    SettingOptionView(header: "Human") {
                                        Toggle("", isOn: .constant(true))
                                    }
                                    SettingOptionView(header: "AI") {
                                        Toggle("", isOn: .constant(true))
                                    }

                                }
                        }
                        .scrollContentBackground(.hidden)
                        .padding([.top], height * 0.05)
                        
                        Button {
                            signOut()
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
                    .onAppear {
                        width = geometry.size.width
                        height = geometry.size.height
                    }
                }
                .background(
                    Color(.init(white: 0, alpha: 0.1))
                        .ignoresSafeArea()
                )
            }
            
            
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }

    private func signOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            savedPassword = ""
            savedEmail = ""

        } catch {
            print("Failed to sign out")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.light)
}
