import SwiftUI
import CoreImage.CIFilterBuiltins
import CryptoKit
import Combine

struct DynamicQRCodeView: View {
    // Meminta objek user yang aktif
    let user: UserModel
    
    @State private var currentQRCode: CGImage?
    @State private var timeRemaining = 10
    
    // Timer yang berdetak setiap 1 detik
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Konfigurasi generator QR
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
                // Tampilan fallback jika QR belum siap
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .cornerRadius(12)
                    .overlay(ProgressView())
            }
            
            // Teks hitung mundur (Countdown)
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
    
    // Logika Pembuat QR Code
    private func refreshQRCode() {
        let timestamp = Int(Date().timeIntervalSince1970)
        
        // 1. Buat string untuk ditandatangani
        let dataToSign = "\(user.user_id)|\(timestamp)"
        
        // 2. Hash dengan HMAC
        let signature = HMAC<SHA256>.authenticationCode(for: Data(dataToSign.utf8), using: secretKey)
        let signatureString = Data(signature).base64EncodedString()
        
        // 3. Bentuk Payload JSON (Mempertahankan "user_id")
        let jsonPayload = """
        {
          "user_id": "\(user.user_id)",
          "name": "\(user.name)",
          "timestamp": \(timestamp),
          "signature": "\(signatureString)"
        }
        """
        
        // 4. Generate Gambar
        filter.message = Data(jsonPayload.utf8)
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            // Animasi agar tidak kaku saat QR berubah
            withAnimation {
                currentQRCode = context.createCGImage(scaledImage, from: scaledImage.extent)
            }
        }
    }
}
