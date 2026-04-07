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

import SwiftUI

//struct TaskSheetView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.modelContext) private var modelContext // Akses SwiftData
//    
//    var isEditMode: Bool = false
//    var taskToEdit: TaskModel? // Menggunakan TaskModel langsung
//    
//    @State private var title = ""
//    @State private var notes = ""
//    @State private var taskDate = Date()
//    @State private var isReportTask = false
//    @State private var isPinned = false
//    
//    @State private var showScanner = false
//    @State private var assignedReviewerName: String? = nil
//    @State private var scannedReviewerPayload: QRCodePayload? = nil
//    
//    @State private var scanMessage: String? = nil
//    @State private var scanSuccess = false
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.91, green: 0.94, blue: 0.98).ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                header
//                
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 24) {
//                        
//                        // --- GROUP 1: GENERAL ---
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("General information")
//                                .font(.system(size: 16, weight: .bold))
//                                .foregroundColor(.gray)
//                                .padding(.leading)
//                            
//                            VStack(spacing: 0) {
//                                TextField("Title", text: $title)
//                                    .padding()
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .autocorrectionDisabled()
//                                
//                                Divider().padding(.horizontal)
//                                
//                                TextField("Notes", text: $notes)
//                                    .padding()
//                                    .frame(height: 80, alignment: .topLeading)
//                                    .autocorrectionDisabled()
//                                
//                                Divider().padding(.horizontal)
//                                
//                                DatePicker(selection: $taskDate, displayedComponents: .date) {
//                                    HStack(spacing: 12) {
//                                        Image(systemName: "calendar")
//                                            .font(.system(size: 14, weight: .semibold))
//                                            .foregroundColor(.white)
//                                            .frame(width: 28, height: 28)
//                                            .background(Color.red)
//                                            .cornerRadius(6)
//                                        Text("Date")
//                                    }
//                                }
//                                .padding()
//                                
//                                Divider().padding(.horizontal)
//                                
//                                DatePicker(selection: $taskDate, displayedComponents: .hourAndMinute) {
//                                    HStack(spacing: 12) {
//                                        Image(systemName: "clock.fill")
//                                            .font(.system(size: 14, weight: .semibold))
//                                            .foregroundColor(.white)
//                                            .frame(width: 28, height: 28)
//                                            .background(Color.blue)
//                                            .cornerRadius(6)
//                                        Text("Time")
//                                    }
//                                }
//                                .padding()
//                            }
//                            .background(Color.white)
//                            .cornerRadius(16)
//                        }
//                        
//                        // --- GROUP 2: REVIEWER & VISIBILITY ---
//                        VStack(alignment: .leading, spacing: 8) {
//                            
//                            Text("Visibility & report")
//                                .font(.system(size: 16, weight: .bold))
//                                .foregroundColor(.gray)
//                                .padding(.leading)
//                            
//                            VStack(spacing: 0) {
//                                Toggle(isOn: $isPinned) {
//                                    HStack(spacing: 12) {
//                                        Image(systemName: "pin.fill")
//                                            .font(.system(size: 14, weight: .semibold))
//                                            .foregroundColor(.white)
//                                            .frame(width: 28, height: 28)
//                                            .background(Color.green)
//                                            .cornerRadius(6)
//                                        Text("Pin")
//                                    }
//                                }
//                                .padding()
//                                
//                                Divider().padding(.horizontal)
//                                
//                                Toggle(isOn: $isReportTask) {
//                                    HStack(spacing: 12) {
//                                        Image(systemName: "doc.text.fill")
//                                            .font(.system(size: 14, weight: .semibold))
//                                            .foregroundColor(.white)
//                                            .frame(width: 28, height: 28)
//                                            .background(Color.orange)
//                                            .cornerRadius(6)
//                                        Text("Report Task")
//                                    }
//                                }
//                                .padding()
//                                .disabled(isEditMode) // Tidak bisa diedit saat mode Edit
//                                
//                                // Muncul tepat di bawah toggle jika diaktifkan
//                                if isReportTask {
//                                    Divider().padding(.horizontal)
//                                    reviewerSection
//                                }
//                            }
//                            .background(Color.white)
//                            .cornerRadius(16)
//                        }
//                        
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                    .padding(.bottom, 40)
//                }
//            }
//        }
//        .onAppear(perform: setupInitialData)
//        .sheet(isPresented: $showScanner) { scannerSheet }
//    }
//    
//    private var header: some View {
//        HStack {
//            Button(action: { presentationMode.wrappedValue.dismiss() }) {
//                Image(systemName: "xmark").font(.system(size: 18, weight: .bold)).foregroundColor(.gray)
//                    .padding(12).background(Color.white).clipShape(Circle())
//            }
//            Spacer()
//            Text(isEditMode ? "Edit and View Task" : "Create Task").font(.system(size: 18, weight: .bold))
//            Spacer()
//            Button(action: saveAction) {
//                Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
//                    .padding(12).background(title.isEmpty ? Color.gray : Color.blue).clipShape(Circle())
//            }
//            .disabled(title.isEmpty)
//        }
//        .padding()
//    }
//
//    private var reviewerSection: some View {
//        HStack {
//            HStack(spacing: 12) {
//                Image(systemName: "person.fill")
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(.white)
//                    .frame(width: 28, height: 28)
//                    .background(Color.purple)
//                    .cornerRadius(6)
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Assign Reviewer").font(.system(size: 16, weight: .semibold))
//                    Text(assignedReviewerName ?? (isEditMode ? (taskToEdit?.reviewer?.name ?? "No reviewer") : "Scan reviewer's QR code"))
//                        .font(.system(size: 12)).foregroundColor(.gray)
//                }
//            }
//            
//            Spacer()
//            
//            if !isEditMode {
//                Button(action: { scanMessage = nil; scanSuccess = false; showScanner = true }) {
//                    Image(systemName: "qrcode.viewfinder").font(.system(size: 24)).foregroundColor(.blue)
//                }
//            }
//        }
//        .padding()
//    }
//
//    private var scannerSheet: some View {
//        VStack(spacing: 16) {
//            Text("Scan Reviewer QR").font(.headline).padding(.top, 24)
//            if let msg = scanMessage {
//                Text(msg).font(.subheadline).bold().foregroundColor(scanSuccess ? .green : .red).padding(.horizontal)
//            }
//            QRCameraScanner { code in
//                let result = ScannerValidator.processScan(jsonString: code, requiredReviewerID: "")
//                scanMessage = result.message; scanSuccess = result.success
//                if result.success, let payload = result.payload {
//                    self.scannedReviewerPayload = payload
//                    self.assignedReviewerName = payload.name
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { showScanner = false }
//                }
//            }
//            .frame(width: 250, height: 250).cornerRadius(16).padding()
//            Button("Cancel") { showScanner = false }.foregroundColor(.red)
//            Spacer()
//        }
//        .presentationDetents([.medium])
//    }
//
//    // --- LOGIKA SWIFTDATA ---
//    
//    private func setupInitialData() {
//        if isEditMode, let task = taskToEdit {
//            title = task.title
//            notes = task.notes
//            taskDate = task.dueDate
//            isPinned = task.isPinned
//            assignedReviewerName = task.reviewer?.name
//            // Deteksi otomatis apakah ini Report Task sebelumnya
//            isReportTask = task.reviewer != nil
//        }
//    }
//
//    private func saveAction() {
//        if isEditMode, let task = taskToEdit {
//            // Update objek yang sudah ada
//            task.title = title
//            task.notes = notes
//            task.dueDate = taskDate
//            task.isPinned = isPinned
//            // Reviewer tidak diubah di sini untuk menjaga integritas data
//        } else {
//            // Buat objek baru
//            let newTask = TaskModel(
//                taskId: Int.random(in: 1000...9999),
//                title: title,
//                notes: notes,
//                status: "todo",
//                dueDate: taskDate,
//                isPinned: isPinned
//            )
//            
//            // HANYA simpan reviewer jika "Report Task" diaktifkan
//            if isReportTask, let payload = scannedReviewerPayload {
//                newTask.reviewer = UserProfileModel(
//                    user_id: payload.user_id, // Sesuaikan dengan nama variabel di UserProfileModel
//                    name: payload.name,
//                    timestamp: Int(payload.timestamp),
//                    signature: payload.signature
//                )
//            }
//            
//            modelContext.insert(newTask)
//        }
//        
//        try? modelContext.save()
//        presentationMode.wrappedValue.dismiss()
//    }
//}


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
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    
    var isEditMode: Bool = false
    var taskToEdit: TaskModel?
    
    @State private var title = ""
    @State private var notes = ""
    @State private var taskDate = Date()
    @State private var isReportTask = false
    @State private var isPinned = false
    
    // State untuk Reviewer & Scanner
    @State private var selectedReviewer: ReviewerModel? = nil
    @State private var showReviewerList = false
    @State private var showScanner = false
    @State private var scanMessage: String? = nil
    @State private var scanSuccess = false

    var body: some View {
        ZStack {
            Color(red: 0.91, green: 0.94, blue: 0.98).ignoresSafeArea()
            
            VStack(spacing: 20) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // --- GROUP 1: GENERAL ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("General information")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.leading)
                            
                            VStack(spacing: 0) {
                                TextField("Title", text: $title)
                                    .padding()
                                    .font(.system(size: 16, weight: .semibold))
                                    .autocorrectionDisabled()
                                
                                Divider().padding(.horizontal)
                                
                                TextField("Notes", text: $notes)
                                    .padding()
                                    .frame(height: 80, alignment: .topLeading)
                                    .autocorrectionDisabled()
                                
                                Divider().padding(.horizontal)
                                
                                DatePicker(selection: $taskDate, displayedComponents: .date) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "calendar").font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 28, height: 28).background(Color.red).cornerRadius(6)
                                        Text("Date")
                                    }
                                }
                                .padding()
                                
                                Divider().padding(.horizontal)
                                
                                DatePicker(selection: $taskDate, displayedComponents: .hourAndMinute) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "clock.fill").font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 28, height: 28).background(Color.blue).cornerRadius(6)
                                        Text("Time")
                                    }
                                }
                                .padding()
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        
                        // --- GROUP 2: VISIBILITY & REVIEWER ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Visibility & report")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.leading)
                            
                            VStack(spacing: 0) {
                                Toggle(isOn: $isPinned) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "pin.fill").font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 28, height: 28).background(Color.green).cornerRadius(6)
                                        Text("Pin")
                                    }
                                }
                                .padding()
                                
                                Divider().padding(.horizontal)
                                
                                Toggle(isOn: $isReportTask) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.fill").font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 28, height: 28).background(Color.orange).cornerRadius(6)
                                        Text("Report Task")
                                    }
                                }
                                .padding()
                                .disabled(isEditMode) // Terkunci saat mode Edit
                                
                                // Jika "Report Task" ON, munculkan menu Reviewer
                                if isReportTask {
                                    Divider().padding(.horizontal)
                                    
                                    // 1. Menu Pilih Reviewer dari List
                                    Button(action: { if !isEditMode { showReviewerList = true } }) {
                                        HStack(spacing: 12) {
                                            if let reviewer = selectedReviewer {
                                                // Jika sudah ada reviewer terpilih
                                                ZStack {
                                                    Circle().fill(Color.purple).frame(width: 28, height: 28)
                                                    Text(String(reviewer.name.prefix(2)).uppercased()).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                                                }
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(reviewer.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                                                    Text(reviewer.user_id).font(.system(size: 12)).foregroundColor(.gray)
                                                }
                                            } else {
                                                // Jika belum ada reviewer
                                                Image(systemName: "person.badge.plus").font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 28, height: 28).background(Color.purple).cornerRadius(6)
                                                Text("Select Reviewer").font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                                            }
                                            
                                            Spacer()
                                            if !isEditMode { Image(systemName: "chevron.right").foregroundColor(.gray).font(.system(size: 14)) }
                                        }
                                        .padding()
                                    }
                                    .disabled(isEditMode)
                                    
                                    // 2. Menu Scan QR Code (Hanya untuk tambah kontak baru)
                                    if !isEditMode {
                                        Divider().padding(.horizontal)
                                        Button(action: { showScanner = true }) {
                                            HStack(spacing: 12) {
                                                Image(systemName: "qrcode.viewfinder").font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 28, height: 28).background(Color.indigo).cornerRadius(6)
                                                Text("Scan QR to Add New").font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding()
                                        }
                                    }
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
        .sheet(isPresented: $showScanner) { scannerSheet }
        .sheet(isPresented: $showReviewerList) {
            ReviewerSelectionSheetView(onSelect: { reviewer in
                self.selectedReviewer = reviewer
            })
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark").font(.system(size: 18, weight: .bold)).foregroundColor(.gray)
                    .padding(12).background(Color.white).clipShape(Circle())
            }
            Spacer()
            Text(isEditMode ? "Edit and View Task" : "Create Task").font(.system(size: 18, weight: .bold))
            Spacer()
            Button(action: saveAction) {
                Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    .padding(12).background(title.isEmpty ? Color.gray : Color.blue).clipShape(Circle())
            }
            .disabled(title.isEmpty)
        }
        .padding()
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
    
    private func setupInitialData() {
        if isEditMode, let task = taskToEdit {
            title = task.title
            notes = task.notes
            taskDate = task.dueDate
            isPinned = task.isPinned
            selectedReviewer = task.reviewer
            isReportTask = task.reviewer != nil
        }
    }

    private func saveAction() {
        if isEditMode, let task = taskToEdit {
            task.title = title
            task.notes = notes
            task.dueDate = taskDate
            task.isPinned = isPinned
        } else {
            let newTask = TaskModel(
                taskId: Int.random(in: 1000...9999),
                title: title,
                notes: notes,
                status: "todo",
                dueDate: taskDate,
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
}

