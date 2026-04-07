//
//  SecureQRSheetView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import CryptoKit
import Combine
import SwiftData

// MARK: - 4. Secure QR Sheet View

struct SecureQRSheetView: View {
    // Meminta tipe data UserProfileModel langsung
    let userProfile: UserModel
    
    @State private var currentQRCode: CGImage?
    @State private var timeRemaining = 10
    
    let qrManager = QRManager()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(red: 0.91, green: 0.94, blue: 0.98).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Ready to Approve")
                    .font(.title2)
                    .bold()
                    .padding(.top, 30)
                
                Text("Have the requester scan this QR code to confirm your approval.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 16) {
                    if let qrCode = currentQRCode {
                        Image(qrCode, scale: 1.0, orientation: .up, label: Text("Secure QR Code"))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 260, height: 260)
                            .cornerRadius(16)
                            .overlay(ProgressView())
                    }
                    
                    VStack(spacing: 5) {
                        Text("Code refreshes in:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(timeRemaining)s")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(timeRemaining <= 3 ? .red : .blue)
                    }
                }
                .padding(.vertical, 20)
                
                Spacer()
            }
        }
        .onAppear {
            refreshQRCode()
        }
        .onReceive(timer) { _ in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                refreshQRCode()
                timeRemaining = 10
            }
        }
    }
    
    private func refreshQRCode() {
        // Ambil data langsung dari UserProfileModel SwiftData
        let newPayload = qrManager.generateSecurePayload(userID: userProfile.user_id, userName: userProfile.name)
        currentQRCode = qrManager.generateQRImage(from: newPayload)
    }
}

class QRManager {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    let secretKey = SymmetricKey(data: Data("OfflineAccountabilityAppSecret2026".utf8))
    
    func generateSecurePayload(userID: String, userName: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let dataToSign = "\(userID)|\(timestamp)"
        
        let signature = HMAC<SHA256>.authenticationCode(for: Data(dataToSign.utf8), using: secretKey)
        let signatureString = Data(signature).base64EncodedString()
        
        return """
        {
          "user_id": "\(userID)",
          "name": "\(userName)",
          "timestamp": \(timestamp),
          "signature": "\(signatureString)"
        }
        """
    }
    
    func generateQRImage(from string: String) -> CGImage? {
        filter.message = Data(string.utf8)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        return context.createCGImage(scaledImage, from: scaledImage.extent)
    }
}

