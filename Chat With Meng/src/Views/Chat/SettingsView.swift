//
//  SettingsView.swift
//  Chat With Meng
//
//  Created by Yumeng Liu on 10/10/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100

    @AppStorage("saved_email") var savedEmail: String = ""
    @AppStorage("saved_password") var savedPassword: String = ""

    var body: some View {
        GeometryReader {
            geometry in
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
                                .preferredColorScheme(.dark)
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
                            Text("Hello")
                            Text("Hello")
                            Text("Hello")
                            Text("Hello")
                        }

                        Section(header: Text("Notifications")) {
                            Text("Hello")
                            Text("Hello")
                            Text("Hello")

                        }
                    }
                    .padding([.top], height * 0.05)
                    
                    Button {
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
                    .padding([.bottom], height * 0.13)
                    .padding([.leading, .trailing])
                    
                    Spacer()

                }
                .onAppear {
                    width = geometry.size.width
                    height = geometry.size.height
                }
            }
        }

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
        .background(
            Color(.init(white: 0, alpha: 0.1))
                .ignoresSafeArea()
        )
        .preferredColorScheme(.dark)
}
