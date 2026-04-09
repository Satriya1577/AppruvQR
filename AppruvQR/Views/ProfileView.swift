//
//  ProfileView.swift
//  AppruvQR
//
//  Created by Ardaly Joshua on 06/04/26.
//

import SwiftUI
import CryptoKit
import SwiftData

struct ProfileView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserModel]

    private var currentUser: UserModel? {
        profiles.first
    }

    @State private var inputName: String = ""
    @State private var showEditAlert = false
    @State private var editNameInput = ""

    private var userName: String {
        currentUser?.name ?? "Alphonso Davies"
    }

    private var initials: String {
        userName
            .components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }

    var body: some View {
        ZStack {
            Color(red: 0.851, green: 0.894, blue: 0.949)
                .ignoresSafeArea()

            if currentUser == nil {
                VStack(spacing: 20) {
                    Text("Welcome!!!")
                        .font(.system(size: 24, weight: .bold))

                    Text("Please enter your name to create your account and generate your approval QR Code.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    TextField("Your Name", text: $inputName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)

                    Button(action: createNewUser) {
                        Text("Create Profile")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(inputName.isEmpty)
                    .opacity(inputName.isEmpty ? 0.5 : 1.0)

                    Spacer()
                }
                .padding(.top, 40)
            } else {
                VStack(spacing: 25) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 180, height: 180)

                        Text(initials)
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                    VStack(spacing: 8) {
                        Text(userName)
                            .font(.system(size: 28, weight: .bold))
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
        // ✅ Modifier diletakkan langsung menempel di ZStack utama
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if currentUser != nil {
                    Button(action: {
                        editNameInput = userName
                        showEditAlert = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .alert("Edit Profile", isPresented: $showEditAlert) {
            TextField("New Name", text: $editNameInput)
            Button("Save", action: updateUserName)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your new profile name.")
        }
    }

    private func createNewUser() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let timestampData = Data(String(timestamp).utf8)
        let hash = SHA256.hash(data: timestampData)
        let generatedID = hash.compactMap { String(format: "%02x", $0) }.joined().prefix(12).description

        let newUser = UserModel(
            user_id: generatedID,
            name: inputName,
            timestamp: timestamp,
            signature: ""
        )

        modelContext.insert(newUser)
        try? modelContext.save()
    }

    private func updateUserName() {
        guard let user = currentUser, !editNameInput.isEmpty else { return }

        user.name = editNameInput
        try? modelContext.save()
    }
}

#Preview {
    ProfileView()
}
