//
//  ReviewerSelectionSheetView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//

import SwiftUI
import SwiftData

/// sheet untuk menampilkan card list reviewer
struct ReviewerSelectionSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Menarik semua data UserProfileModel yang tersimpan di SwiftData
    @Query(sort: \ReviewerModel.name) private var savedReviewers: [ReviewerModel]
    
    var onSelect: (ReviewerModel) -> Void
    
    var body: some View {
        NavigationView {
            List {
                if savedReviewers.isEmpty {
                    Text("No reviewers saved yet. Close this and scan a QR code to add one.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(savedReviewers) { reviewer in
                        Button(action: {
                            onSelect(reviewer)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 16) {
                                // Avatar Lingkaran dengan Inisial
                                ZStack {
                                    Circle().fill(Color.purple).frame(width: 40, height: 40)
                                    Text(String(reviewer.name.prefix(2)).uppercased())
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // Detail Reviewer
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reviewer.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text(reviewer.user_id)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Select Reviewer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}


