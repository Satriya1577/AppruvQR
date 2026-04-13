//
//  UserModel+Streak.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//
import Foundation

extension UserModel {
    // jika user berhasil menyelesaikan tugas
    func updateStreak() {
        let calendar = Calendar.current
        let now = Date()
        
        // streak pertama
        guard let lastUpdated = streakLastUpdated else {
            streakCount = 1
            streakLastUpdated = now
            return
        }
        
        // jika last update-nya hari ini
        if calendar.isDateInToday(lastUpdated) {
            print("Peringatan: Streak sudah ditambahkan hari ini.")
            return
        }
        
        // jika health habis, streak tidak bisa dilanjutkan sampai recovery.
        guard streakHealthCount > 0 else {
            return
        }
        
        streakCount += 1
        streakLastUpdated = now
    }
    
    func applyMissedDayPenaltyIfNeeded(referenceDate: Date = Date()) {
        guard streakHealthCount > 0 else { return }
        
        let calendar = Calendar.current
        guard let lastUpdated = streakLastUpdated else { return }
        
        if calendar.isDateInToday(lastUpdated) || calendar.isDateInYesterday(lastUpdated) {
            return
        }
        
        if let lastPenaltyDate = streakLastHealthPenaltyDate,
           calendar.isDate(lastPenaltyDate, inSameDayAs: referenceDate) {
            return
        }
        
        decrementHealth()
        streakLastHealthPenaltyDate = referenceDate
    }
    
    func resetLostStreak() {
        streakCount = 0
        streakHealthCount = 3
        streakLastUpdated = nil
        isStreakLost = false
        pendingRecoveryStreakCount = nil
        streakLastHealthPenaltyDate = nil
    }
    
    func recoverLostStreakAfterReflection() {
        if let previousStreak = pendingRecoveryStreakCount {
            streakCount = previousStreak
        }
        streakHealthCount = 3
        streakLastUpdated = Date()
        isStreakLost = false
        pendingRecoveryStreakCount = nil
        streakLastHealthPenaltyDate = nil
    }
    
    // Mengurangi health streak
    private func decrementHealth() {
        streakHealthCount -= 1
        
        if streakHealthCount == 0 {
            if pendingRecoveryStreakCount == nil {
                pendingRecoveryStreakCount = streakCount
            }
            isStreakLost = true
        }
    }
}
