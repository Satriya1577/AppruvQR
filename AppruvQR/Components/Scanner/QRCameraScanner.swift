//
//  QRCameraScanner.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 10/04/26.
//
import SwiftUI

struct QRCameraScanner: UIViewControllerRepresentable {
    var didFindCode: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) { }
    
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
