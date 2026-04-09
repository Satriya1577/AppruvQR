//
//  ReflectionView.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 08/04/26.
//

import SwiftUI

struct ReflectionView: View {
    @Environment(\.dismiss) private var dismiss

    var onSharedSuccess: () -> Void

    @State private var reflectionText = ""
    @State private var showWhatsAppModal = false
    @State private var showShareErrorAlert = false

    private let appBackground = Color(red: 215 / 255.0, green: 228 / 255.0, blue: 243 / 255.0)
    private let titleColor = Color(red: 0.10, green: 0.17, blue: 0.30)
    private let shareButtonColor = Color(red: 45 / 255.0, green: 84 / 255.0, blue: 165 / 255.0)

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                backButton

                Text("Take a moment")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(titleColor)

                Text("What made you lose your streak?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, -6)

                reflectionCard

                shareButton

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showWhatsAppModal) {
            whatsappShareModal
        }
        .alert("Share Failed", isPresented: $showShareErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("WhatsApp tidak tersedia atau proses share gagal.")
        }
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var reflectionCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )

            TextEditor(text: $reflectionText)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .font(.system(size: 14))
                .padding(8)

            if trimmedReflection.isEmpty {
                Text("Type in your reflection")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.top, 18)
                    .padding(.leading, 14)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }

    private var shareButton: some View {
        Button {
            showWhatsAppModal = true
        } label: {
            Text("Share")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(shareButtonColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(trimmedReflection.isEmpty)
        .opacity(trimmedReflection.isEmpty ? 0.55 : 1)
    }

    private var whatsappShareModal: some View {
        VStack(spacing: 16) {
            Text("Share ke WhatsApp")
                .font(.headline)

            Text("Bagikan reflection kamu untuk melanjutkan streak.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button {
                shareToWhatsApp()
            } label: {
                Text("Share to WhatsApp")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }

            Button("Cancel") {
                showWhatsAppModal = false
            }
            .foregroundColor(.red)
        }
        .padding()
        .presentationDetents([.fraction(0.32)])
    }

    private var trimmedReflection: String {
        reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func shareToWhatsApp() {
        let encodedText = trimmedReflection.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "whatsapp://send?text=\(encodedText)") else {
            showShareErrorAlert = true
            return
        }

        UIApplication.shared.open(url, options: [:]) { accepted in
            if accepted {
                showWhatsAppModal = false
                onSharedSuccess()
                dismiss()
            } else {
                showShareErrorAlert = true
            }
        }
    }
}

#Preview {
    ReflectionView(onSharedSuccess: {})
}

