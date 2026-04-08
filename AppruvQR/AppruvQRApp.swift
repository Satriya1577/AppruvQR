//
//  AppruvQRApp.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 06/04/26.
//

import SwiftUI
import SwiftData

@main
struct AppruvQRApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [TaskModel.self, UserModel.self, ReviewerModel.self])
    }
}
