//
//  NotificationView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 06/04/26.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    let appBackground = Color("AppBackground") // Light blue background

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
                    Text("Notifications")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Button("Clear All") {
                        // Action
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 12) {
                        NotificationRow(title: "Completed Task", desc: "Finalize onboarding flow", initials: "MC", color: .indigo, time: "Now")
                        NotificationRow(title: "Completed Task", desc: "Finalize onboarding flow", initials: "GF", color: .teal, time: "Now")
                        NotificationRow(title: "Completed Task", desc: "Finalize onboarding flow", initials: "AS", color: .orange, time: "Now")
                        NotificationRow(title: "Completed Task", desc: "Finalize onboarding flow", initials: "AK", color: .yellow, time: "Now")
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct NotificationRow: View {
    var title: String
    var desc: String
    var initials: String
    var color: Color
    var time: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(initials)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(color))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    NotificationView()
}
