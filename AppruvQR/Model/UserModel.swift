//
//  UserPofileModel.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//

import Foundation
import SwiftData

@Model
class UserModel {
    var user_id: String
    var name: String
    var timestamp: Int
    var signature: String
    
    // Minimal 0
    var streakCount: Int = 0 {
        didSet {
            if streakCount < 0 {
                streakCount = 0
            }
        }
    }
    
    // Maksimal 3 (dan minimal 0 agar tidak minus)
    var streakHealthCount: Int = 3 {
        didSet {
            if streakHealthCount > 3 {
                streakHealthCount = 3
            } else if streakHealthCount < 0 {
                streakHealthCount = 0
            }
        }
    }
    
    // Menyimpan waktu terakhir diupdate
    var streakLastUpdated: Date?
    
    init(user_id: String, name: String, timestamp: Int, signature: String) {
        self.user_id = user_id
        self.name = name
        self.timestamp = timestamp
        self.signature = signature
    }
    
    // MARK: - Helper Methods (Opsional tapi sangat disarankan)
    
    /// Panggil fungsi ini jika user berhasil menyelesaikan tugas
    func updateStreak() {
        let calendar = Calendar.current
        let now = Date()
        
        // 1. Jika belum pernah ada streak sama sekali (Pertama kali main)
        guard let lastUpdated = streakLastUpdated else {
            streakCount = 1
            streakLastUpdated = now
            return
        }
        
        // 2. Jika last update-nya hari ini -> JANGAN TAMBAH (Keluar dari fungsi)
        if calendar.isDateInToday(lastUpdated) {
            print("Peringatan: Streak sudah ditambahkan hari ini.")
            return
        }
        
        // 3. Jika last update-nya kemarin -> TAMBAH 1
        if calendar.isDateInYesterday(lastUpdated) {
            streakCount += 1
            streakLastUpdated = now
        }
        // 4. Jika bolong lebih dari 1 hari -> kurangi health nya
        else {
           decrementHealth()
        }
    }
    
    /// Mengurangi health streak
    private func decrementHealth() {
        streakHealthCount -= 1
        
        if streakHealthCount == 0 {
            // 
        }
    }
}
