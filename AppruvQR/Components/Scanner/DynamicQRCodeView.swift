import SwiftUI
import CoreImage.CIFilterBuiltins
import CryptoKit
import Combine

struct DynamicQRCodeView: View {
    let user: UserModel
    
    @State private var currentQRCode: CGImage?
    @State private var timeRemaining = 10
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    private let secretKey = SymmetricKey(data: Data("OfflineAccountabilityAppSecret2026".utf8))
    
    var body: some View {
        VStack(spacing: 16) {
            if let qrCode = currentQRCode {
                Image(qrCode, scale: 1.0, orientation: .up, label: Text("Secure QR Code"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                // Tampilan fallback kalo QR belum siap
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .cornerRadius(12)
                    .overlay(ProgressView())
            }
            
            // Countdown
            Text("QR Refreshes in: \(timeRemaining)s")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(timeRemaining <= 3 ? .red : .black)
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
    
    // Logika QR Code
    private func refreshQRCode() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let dataToSign = "\(user.user_id)|\(timestamp)"
        let signature = HMAC<SHA256>.authenticationCode(for: Data(dataToSign.utf8), using: secretKey)
        let signatureString = Data(signature).base64EncodedString()
        let jsonPayload = """
        {
          "user_id": "\(user.user_id)",
          "name": "\(user.name)",
          "timestamp": \(timestamp),
          "signature": "\(signatureString)"
        }
        """
        
        filter.message = Data(jsonPayload.utf8)
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            withAnimation {
                currentQRCode = context.createCGImage(scaledImage, from: scaledImage.extent)
            }
        }
    }
}
