//
//  ProfileView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 06/04/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import CryptoKit
import Combine
import SwiftData




// MARK: - 3. Profile View

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // --- PENGGUNAAN SWIFTDATA ---
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserModel] // Ambil semua profil dari database
    
    // Karena ini device personal, asumsikan hanya ada 1 profil utama (index pertama)
    private var currentUser: UserModel? {
        profiles.first
    }
    
    // Input State
    @State private var inputName: String = ""
    @State private var showEditAlert = false
    @State private var editNameInput = ""
    @State private var showQRSheet = false
    
    let appBackground = Color("AppBackground")
    
    // Helper to get initials
    var userInitials: String {
        guard let name = currentUser?.name, !name.isEmpty else { return "UK" }
        let words = name.split(separator: " ")
        if let firstWord = words.first {
            return String(firstWord.prefix(2)).uppercased()
        }
        return "UK"
    }
    
    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Profile")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    
                    // Tampilkan icon QR hanya jika data user ada
                    if currentUser != nil {
                        Button(action: { showQRSheet = true }) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }
                }
                .padding()
                
                if currentUser == nil {
                    // --- NEW USER FLOW ---
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
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .disabled(inputName.isEmpty)
                        .opacity(inputName.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.top, 40)
                    Spacer()
                    
                } else {
                    // --- REGISTERED USER FLOW ---
                    VStack(spacing: 24) {
                        // Avatar View
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.blue, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Text(userInitials)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(currentUser?.name ?? "Unknown")
                                .font(.system(size: 28, weight: .bold))
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    editNameInput = currentUser?.name ?? ""
                                    showEditAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 12))
                                        Text("Edit profile")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        // Action sheet (Alert) to edit name
        .alert("Edit Profile", isPresented: $showEditAlert) {
            TextField("New Name", text: $editNameInput)
            Button("Save", action: updateUserName)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your new profile name.")
        }
        // Sheet for Secure QR Code
        .sheet(isPresented: $showQRSheet) {
            if let user = currentUser {
                SecureQRSheetView(userProfile: user)
            }
        }
    }
    
    // MARK: - Actions & Logic (SwiftData)
    
    private func createNewUser() {
        let timestamp = Int(Date().timeIntervalSince1970)
        
        // Hash the timestamp to create a unique ID
        let timestampData = Data(String(timestamp).utf8)
        let hash = SHA256.hash(data: timestampData)
        let generatedID = hash.compactMap { String(format: "%02x", $0) }.joined().prefix(12).description
        
        // Buat objek SwiftData baru
        let newUser = UserModel(
            user_id: generatedID,
            name: inputName,
            timestamp: timestamp,
            signature: "" // Signature di-generate secara real-time di QRManager
        )
        
        // Masukkan ke database dan simpan
        modelContext.insert(newUser)
        try? modelContext.save()
    }
    
    private func updateUserName() {
        guard let user = currentUser, !editNameInput.isEmpty else { return }
        
        // Ubah langsung di objeknya (SwiftData akan otomatis melacak perubahannya)
        user.name = editNameInput
        
        // Simpan perubahan ke database
        try? modelContext.save()
    }
}

#Preview {
    ProfileView()
}

