//
//  ProfileView.swift
//  AppruvQR
//
//  Created by Ardaly Joshua on 06/04/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserModel]

    // Inisialisasi ViewModel
    @State private var viewModel = ProfileViewModel()

    private var currentUser: UserModel? {
        profiles.first
    }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            if currentUser == nil {
                // --- NEW USER FLOW ---
                VStack(spacing: 20) {
                    Text("Welcome!!!")
                        .font(.system(size: 24, weight: .bold))

                    Text("Please enter your name to create your account and generate your approval QR Code.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    // Binding langsung ke ViewModel
                    TextField("Your Name", text: $viewModel.inputName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)

                    Button(action: { viewModel.createNewUser(context: modelContext) }) {
                        Text("Create Profile")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.inputName.isEmpty)
                    .opacity(viewModel.inputName.isEmpty ? 0.5 : 1.0)

                    Spacer()
                }
                .padding(.top, 40)
                
            } else {
                // --- REGISTERED USER FLOW ---
                VStack(spacing: 25) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 180, height: 180)

                        // Memanggil fungsi dari ViewModel
                        Text(viewModel.initials(for: currentUser))
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                    VStack(spacing: 8) {
                        Text(viewModel.userName(for: currentUser))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(viewModel.userId(for: currentUser))
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }

                    if let user = currentUser {
                        DynamicQRCodeView(user: user)
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if currentUser != nil {
                    Button(action: {
                        viewModel.editNameInput = viewModel.userName(for: currentUser)
                        viewModel.showEditAlert = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            
                    }
                }
            }
        }
        .alert("Edit Profile", isPresented: $viewModel.showEditAlert) {
            TextField("New Name", text: $viewModel.editNameInput)
            Button("Save") {
                viewModel.updateUserName(for: currentUser, context: modelContext)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your new profile name.")
        }
    }
}

#Preview {
    ProfileView()
}
