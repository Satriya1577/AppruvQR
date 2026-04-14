//
//  ProfileViewModel.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 14/04/26.
//

import SwiftUI
import CryptoKit
import SwiftData

@Observable
class ProfileViewModel {
    // State untuk UI
    var inputName: String = ""
    var showEditAlert = false
    var editNameInput = ""

    // Helper untuk UI
    func userName(for user: UserModel?) -> String {
        return user?.name ?? "Alphonso Davies"
    }
    
    func userId(for user: UserModel?) -> String {
        return user?.user_id ?? "null"
    }

    func initials(for user: UserModel?) -> String {
        return userName(for: user)
            .components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }

    // Aksi Database (Menerima modelContext dari View)
    func createNewUser(context: ModelContext) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let timestampData = Data(String(timestamp).utf8)
        let hash = SHA256.hash(data: timestampData)
        let generatedID = hash.compactMap { String(format: "%02x", $0) }.joined().prefix(12).description

        let newUser = UserModel(
            user_id: generatedID,
            name: inputName,
            timestamp: timestamp,
            signature: ""
        )

        context.insert(newUser)
        try? context.save()
    }

    func updateUserName(for user: UserModel?, context: ModelContext) {
        guard let user = user, !editNameInput.isEmpty else { return }

        user.name = editNameInput
        try? context.save()
    }
}
