//
//  TaskReviewerScannerSheet.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 10/04/26.
//
import SwiftUI
import SwiftData

struct TaskReviewerScannerSheet: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var isPresented: Bool
    @Binding var selectedReviewer: ReviewerModel?

    @State private var scanMessage: String?
    @State private var scanSuccess = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Scan to Add Reviewer")
                .font(.headline)
                .padding(.top, 24)

            if let msg = scanMessage {
                Text(msg)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(scanSuccess ? .green : .red)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }

            QRCameraScanner { code in
                handleScan(code)
            }
            .frame(width: 250, height: 250)
            .cornerRadius(16)
            .padding()

            Button("Cancel") {
                isPresented = false
            }
            .foregroundColor(.red)

            Spacer()
        }
        .presentationDetents([.medium])
    }

    private func handleScan(_ code: String) {
        let result = ScannerValidator.processScan(jsonString: code, requiredReviewerID: "")

        withAnimation {
            scanMessage = result.message
            scanSuccess = result.success
        }

        guard result.success, let payload = result.payload else { return }

        let descriptor = FetchDescriptor<ReviewerModel>(
            predicate: #Predicate { $0.user_id == payload.user_id }
        )

        do {
            let existingReviewers = try modelContext.fetch(descriptor)

            if let existingReviewer = existingReviewers.first {
                existingReviewer.name = payload.name
                existingReviewer.timestamp = Int(payload.timestamp)
                existingReviewer.signature = payload.signature
                selectedReviewer = existingReviewer
                scanMessage = "Contact \(payload.name) updated and selected!"
            } else {
                let newReviewer = ReviewerModel(
                    user_id: payload.user_id,
                    name: payload.name,
                    timestamp: Int(payload.timestamp),
                    signature: payload.signature
                )
                modelContext.insert(newReviewer)
                selectedReviewer = newReviewer
                scanMessage = "New contact \(payload.name) added successfully!"
            }

            try? modelContext.save()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isPresented = false
            }
        } catch {
            print("Failed to check database: \(error)")
        }
    }
}
