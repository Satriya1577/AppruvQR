//
//  StreakView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//

import SwiftUI
import SwiftData


struct StreakView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // --- PENGGUNAAN SWIFTDATA ---
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserModel]
    
    // Mengambil profil pertama (satu-satunya user)
    private var currentUser: UserModel? {
        profiles.first
    }
    
    // Warna background sesuai dengan hex #D7E4F3
    let appBackground = Color(red: 215 / 255.0, green: 228 / 255.0, blue: 243 / 255.0)
    let darkBlueText = Color(red: 0.15, green: 0.25, blue: 0.45)
    
    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()
            
            VStack {
                // 1. Header (Tombol Back) - Tetap tampil meski data kosong
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // 2. Main Content (Hanya tampil jika currentUser ada)
                if let user = currentUser {
                    VStack(spacing: 20) {
                        
                        // --- Speech Bubble ---
                        VStack(spacing: 0) {
                            Text("Don't break the\nstreak! Complete a\ntask or share your\nprogress 🔥")
                                .font(.system(size: 11, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            // Segitiga kecil untuk ekor balon kata
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .offset(y: -2)
                                .padding(.trailing, 40)
                        }
                        .padding(.leading, -80)
                        .offset(y: 10)
                        
                        // --- Face Icon & Flame ---
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 220, height: 220)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                            
                            // Menampilkan ekspresi wajah
                            Image(systemName: faceIconName)
                                .font(.system(size: 200, weight: .light))
                                .foregroundColor(darkBlueText)
                        }
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.orange)
                                .offset(x: 10, y: 10)
                                .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.bottom, 16)
                        
                        // --- Streak Numbers ---
                        Text("\(user.streakCount)")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: darkBlueText, radius: 1, x: -2, y: -2)
                            .shadow(color: darkBlueText, radius: 1, x: 2, y: 2)
                            .shadow(color: darkBlueText, radius: 1, x: -2, y: 2)
                            .shadow(color: darkBlueText, radius: 1, x: 2, y: -2)
                        
                        Text("days streak!")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(darkBlueText)
                            .padding(.top, -15)
                        
                        Text("You've completed your tasks consistently this week.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // --- Health Indicator (Hati) ---
                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < user.streakHealthCount ? "heart.fill" : "heart")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(darkBlueText)
                            }
                        }
                        .padding(.top, 16)
                    }
                }
                else {
                    // Jika data belum ada (opsional, sebagai pengaman)
                    Text("Memuat data streak...")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Helper Logic
    
    private var faceIconName: String {
        // Ambil nyawa dari currentUser, jika nil (kosong), anggap 3.
        let health = currentUser?.streakHealthCount ?? 3
        
        switch health {
        case 3:
            return "face.smiling"
        case 2:
            return "face.dashed"
        case 1, 0:
            return "face.frowning"
        default:
            return "face.smiling"
        }
    }
}

// MARK: - Preview (Ditambahkan ModelContainer agar tidak crash)
#Preview {
    StreakView()
}
