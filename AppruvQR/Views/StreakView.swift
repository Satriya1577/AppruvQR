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
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserModel]
    var currentUser: UserModel? {
        profiles.first
    }
    
    let appBackground = Color("AppBackground")
    let darkBlueText = Color("BlueThis")
    
    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()
            
            VStack {
                Spacer()
                if let user = currentUser {
                    VStack(spacing: 20) {
                        
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
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .offset(y: -2)
                                .padding(.trailing, 40)
                        }
                        .padding(.leading, -80)
                        .offset(y: 10)
                        
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 220, height: 220)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                            
                            Image(faceImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 170, height: 170)
                        }
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.orange)
                                .offset(x: -10, y: -20)
                                .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.bottom, 16)
                        
                        Text("\(user.streakCount)")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .streakOutline(color: darkBlueText)
                        
                        
                        Text("days streak!")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(darkBlueText)
                            .padding(.top, -15)
                        
                        Text("You've completed your tasks consistently this week.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // health indicator
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
                    VStack {
                        Text("Create user first to get started !").foregroundColor(.gray)
                            .font(.system(size: 18, weight: .bold))
                        
                        NavigationLink(destination: ProfileView()) {
                            Text("Go to profile page")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color("BlueThis"))
                                .clipShape(Capsule())
                        }
                    }
                }
                Spacer()
                Spacer()
            }
        }
        .navigationTitle("Streaks")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}


#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserModel.self, configurations: config)
        
        // dummy data
        let dummyUser = UserModel(
            user_id: "prev_01",
            name: "Satriya",
            timestamp: Int(Date().timeIntervalSince1970),
            signature: "dummy_sig"
        )
        dummyUser.streakCount = 25
        dummyUser.streakHealthCount = 2
        
        container.mainContext.insert(dummyUser)
        return StreakView()
            .modelContainer(container)
        
    } catch {
        return Text("Gagal memuat preview: \(error.localizedDescription)")
    }
}
