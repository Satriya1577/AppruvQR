//
//  TaskView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 06/04/26.
//

import SwiftUI
import CryptoKit
import Combine
import AVFoundation
import UIKit
import SwiftData

// MARK: - 2. Scanner Logic & Validator
struct QRCodePayload: Codable {
    let user_id: String
    let name: String
    let timestamp: TimeInterval
    let signature: String
}

struct ScannerValidator {
    static let secretKey = SymmetricKey(data: Data("OfflineAccountabilityAppSecret2026".utf8))
    
    // Parameter dinamis requiredReviewerID
    static func processScan(jsonString: String, requiredReviewerID: String) -> (success: Bool, message: String, payload: QRCodePayload?) {
        
        guard let data = jsonString.data(using: .utf8),
              let payload = try? JSONDecoder().decode(QRCodePayload.self, from: data) else {
            return (false, "[ERROR] QR Code tidak valid atau bukan dari aplikasi ini.", nil)
        }
        
        let currentTimestamp = Date().timeIntervalSince1970
        let ageInSeconds = currentTimestamp - payload.timestamp
        
        if ageInSeconds > 10 {
            return (false, "[ERROR] QR Code Kedaluwarsa! Minta reviewer refresh.", payload)
        }
        if ageInSeconds < -5 {
            return (false, "[ERROR] Waktu tidak sinkron. Cek jam HP.", payload)
        }
        
        let dataToSign = "\(payload.user_id)|\(Int(payload.timestamp))"
        let expectedSignature = HMAC<SHA256>.authenticationCode(for: Data(dataToSign.utf8), using: secretKey)
        let expectedSignatureString = Data(expectedSignature).base64EncodedString()
        
        if payload.signature != expectedSignatureString {
            return (false, "[ERROR] QR Palsu: Signature Kriptografi tidak cocok!", payload)
        }
        
        // Pencocokan ID (Hanya jika ID reviewer di-set)
        if !requiredReviewerID.isEmpty && payload.user_id != requiredReviewerID {
            return (false, "[ERROR] Salah Orang: Tugas ini untuk \(requiredReviewerID), tapi discan oleh \(payload.user_id).", payload)
        }
        
        return (true, "Disetujui oleh \(payload.name)!", payload)
    }
}

// MARK: - 4. The Camera Logic (AVFoundation wrapper for SwiftUI)
struct QRCameraScanner: UIViewControllerRepresentable {
    var didFindCode: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didFindCode: didFindCode)
    }
    
    class Coordinator: NSObject, ScannerViewControllerDelegate {
        var didFindCode: (String) -> Void
        init(didFindCode: @escaping (String) -> Void) {
            self.didFindCode = didFindCode
        }
        func scannerViewController(_ controller: ScannerViewController, didScanCode code: String) {
            didFindCode(code)
        }
    }
}

// The actual UIKit Camera Controller
protocol ScannerViewControllerDelegate: AnyObject {
    func scannerViewController(_ controller: ScannerViewController, didScanCode code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch { return }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else { return }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr] // ONLY look for QR codes
        } else { return }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            // Stop scanning once we find a code
            captureSession.stopRunning()
            
            // Send the code back to SwiftUI
            delegate?.scannerViewController(self, didScanCode: stringValue)
        }
    }
}

struct TaskSheetView: View {
    private enum Field {
        case title
        case notes
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [TaskModel]
    
    var isEditMode: Bool = false
    var taskToEdit: TaskModel?
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var taskDate = Date()
    @State private var date: Date? = nil
    @State private var time: Date? = nil
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var isReportTask = false
    @State private var isPinned = false
    @State private var showPinLimitAlert = false
    
    // State untuk Reviewer & Scanner
    @State private var selectedReviewer: ReviewerModel? = nil
    @State private var showReviewerList = false
    @State private var showScanner = false
    @State private var scanMessage: String? = nil
    @State private var scanSuccess = false
    @FocusState private var focusedField: Field?
    
    // Mengecek apakah semua kolom wajib sudah diisi
    private var isFormValid: Bool {
        !title.isEmpty && date != nil && time != nil
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.91, green: 0.94, blue: 0.98).ignoresSafeArea()
            
            VStack(spacing: 20) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading) {
                                TextField("Title", text: $title)
                                    .focused($focusedField, equals: .title)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        focusedField = nil
                                    }
                                    .padding(.bottom, 8)
                                Divider()
                                TextField("Notes", text: $notes)
                                    .focused($focusedField, equals: .notes)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        focusedField = nil
                                    }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)

                            // DATE & TIME
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Date & Time")
                                    .padding(.top, 6)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                VStack(alignment: .leading, spacing: 8) {
                                    // DATE
                                    Button {
                                        withAnimation {
                                            showDatePicker.toggle()
                                            showTimePicker = false
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "calendar")

                                            VStack(alignment: .leading) {
                                                Text("Date")

                                                if let date {
                                                    Text(date, style: .date)
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                } else {
                                                    Text("This field is required")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }

                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    if showDatePicker {
                                        DatePicker(
                                            "",
                                            selection: Binding(
                                                get: { date ?? Date() },
                                                set: { date = $0 }
                                            ),
                                            displayedComponents: .date
                                        )
                                        .datePickerStyle(.graphical)
                                        .labelsHidden()
                                    }

                                    Divider()

                                    // TIME
                                    Button {
                                        withAnimation {
                                            showTimePicker.toggle()
                                            showDatePicker = false
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "clock")

                                            VStack(alignment: .leading) {
                                                Text("Time")

                                                if let time {
                                                    Text(time, style: .time)
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                } else {
                                                    Text("This field is required")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }

                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    if showTimePicker {
                                        DatePicker(
                                            "",
                                            selection: Binding(
                                                get: { time ?? Date() },
                                                set: { time = $0 }
                                            ),
                                            displayedComponents: .hourAndMinute
                                        )
                                        .datePickerStyle(.wheel)
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(spacing: 0) {
                                Toggle(isOn: $isReportTask) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.black)
                                        Text("Report Task")
                                    }
                                }
                                .padding()
                                .disabled(isEditMode)

                                if isReportTask {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Report Task to:")
                                            .font(.caption)
                                            .foregroundColor(.red)

                                        Button(action: { if !isEditMode { showReviewerList = true } }) {
                                            HStack(spacing: 12) {
                                                if let reviewer = selectedReviewer {
                                                    ZStack {
                                                        Circle().fill(Color.purple).frame(width: 28, height: 28)
                                                        Text(String(reviewer.name.prefix(2)).uppercased()).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                                                    }
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(reviewer.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                                                        Text(reviewer.user_id).font(.system(size: 12)).foregroundColor(.gray)
                                                    }
                                                } else {
                                                    Image(systemName: "person.badge.plus").font(.system(size: 14, weight: .semibold)).foregroundColor(.black)
                                                    Text("Select Reviewer")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.primary)
                                                }

                                                Spacer()
                                                if !isEditMode {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                                                        .font(.system(size: 14))
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(isEditMode)

                                        if !isEditMode {
                                            Divider()

                                            Button(action: { showScanner = true }) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "qrcode.viewfinder")
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.black)
                                                    Text("Scan QR to Add New")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 12)
                                    .padding(.leading, 28)
                                }

                                Divider().padding(.horizontal)

                                Toggle(isOn: $isPinned) {
                                    HStack(spacing: 12) {
                                        Label("Pin", systemImage: "pin")
                                    }
                                }
                                .padding()

                                if pinLimitExceeded {
                                    Text("Pinned task maksimal 3. Unpin salah satu task dulu.")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal)
                                        .padding(.bottom, 12)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear(perform: setupInitialData)
        .onChange(of: isPinned) { _, newValue in
            if newValue && pinLimitExceeded {
                showPinLimitAlert = true
            }
        }
        .sheet(isPresented: $showScanner) { scannerSheet }
        .sheet(isPresented: $showReviewerList) {
            ReviewerSelectionSheetView(onSelect: { reviewer in
                self.selectedReviewer = reviewer
            })
        }
        .alert("Pin Limit", isPresented: $showPinLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Pinned task maksimal 3. Unpin salah satu task dulu.")
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                focusedField = nil
            }
        )
    }
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Create Task")
                .font(.headline)
            
            Spacer()
            
            Button {
                saveAction()
            } label: {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .clipShape(Circle())
            }
            .disabled(!isFormValid)
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    private var scannerSheet: some View {
        VStack(spacing: 16) {
            Text("Scan to Add Reviewer").font(.headline).padding(.top, 24)
            
            if let msg = scanMessage {
                Text(msg)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(scanSuccess ? .green : .red)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            
            QRCameraScanner { code in
                let result = ScannerValidator.processScan(jsonString: code, requiredReviewerID: "")
                
                // Gunakan animasi agar UI terlihat mulus
                withAnimation {
                    scanMessage = result.message
                    scanSuccess = result.success
                }
                
                if result.success, let payload = result.payload {
                    let targetID = payload.user_id
                    
                    // 1. Buat pencarian ke database berdasarkan user_id
                    let descriptor = FetchDescriptor<ReviewerModel>(
                        predicate: #Predicate { $0.user_id == targetID }
                    )
                    
                    do {
                        // Eksekusi pencarian
                        let existingReviewers = try modelContext.fetch(descriptor)
                        
                        if let existingReviewer = existingReviewers.first {
                            // 2A. JIKA REVIEWER SUDAH ADA:
                            // Update datanya dengan informasi terbaru dari QR
                            existingReviewer.name = payload.name
                            existingReviewer.timestamp = Int(payload.timestamp)
                            existingReviewer.signature = payload.signature
                            
                            // Pilih reviewer ini
                            self.selectedReviewer = existingReviewer
                            self.scanMessage = "Kontak \(payload.name) diperbarui & dipilih!"
                            
                        } else {
                            // 2B. JIKA REVIEWER BELUM ADA:
                            // Simpan sebagai kontak baru
                            let newReviewer = ReviewerModel(
                                user_id: payload.user_id,
                                name: payload.name,
                                timestamp: Int(payload.timestamp),
                                signature: payload.signature
                            )
                            modelContext.insert(newReviewer)
                            self.selectedReviewer = newReviewer
                            self.scanMessage = "Kontak baru \(payload.name) berhasil ditambahkan!"
                        }
                        
                        // Simpan perubahan ke database
                        try? modelContext.save()
                        
                        // Tutup scanner setelah jeda sebentar agar user sempat membaca pesan
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            showScanner = false
                        }
                        
                    } catch {
                        print("Gagal mengecek database: \(error)")
                    }
                }
            }
            .frame(width: 250, height: 250)
            .cornerRadius(16)
            .padding()
            
            Button("Cancel") { showScanner = false }
                .foregroundColor(.red)
            
            Spacer()
        }
        .presentationDetents([.medium])
    }
    
    // --- LOGIKA SWIFTDATA ---

    private var pinnedTodoCountExcludingCurrentTask: Int {
        allTasks.filter {
            $0.isPinned && $0.taskId != taskToEdit?.taskId
        }.count
    }

    private var pinLimitExceeded: Bool {
        isPinned && pinnedTodoCountExcludingCurrentTask >= 3
    }
    
    private func setupInitialData() {
        if isEditMode, let task = taskToEdit {
            title = task.title
            notes = task.notes
            taskDate = task.dueDate
            date = task.dueDate
            time = task.dueDate
            isPinned = task.isPinned
            selectedReviewer = task.reviewer
            isReportTask = task.reviewer != nil
        }
    }
    
    private func saveAction() {
        focusedField = nil
        
        if pinLimitExceeded {
            showPinLimitAlert = true
            return
        }

        let dueDate = combinedDateTime() ?? taskDate

        if isEditMode, let task = taskToEdit {
            task.title = title
            task.notes = notes
            task.dueDate = dueDate
            task.isPinned = isPinned
        } else {
            let newTask = TaskModel(
                taskId: Int.random(in: 1000...9999),
                title: title,
                notes: notes,
                status: "todo",
                dueDate: dueDate,
                isPinned: isPinned
            )

            if isReportTask {
                newTask.reviewer = selectedReviewer
            }

            modelContext.insert(newTask)
        }

        try? modelContext.save()
        presentationMode.wrappedValue.dismiss()
    }

    private func combinedDateTime() -> Date? {
        guard let date, let time else { return nil }

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        return Calendar.current.date(from: dateComponents)
    }
}

#Preview {
    TaskSheetView()
}
