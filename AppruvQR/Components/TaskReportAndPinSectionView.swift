//
//  TaskReportAndPinSectionView.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 13/04/26.
//

import SwiftUI

struct TaskReportAndPinSectionView: View {
    @Binding var isReportTask: Bool
    @Binding var isPinned: Bool
    @Binding var selectedReviewer: ReviewerModel?
    @Binding var showReviewerList: Bool
    @Binding var showScanner: Bool

    let isEditMode: Bool
    let pinLimitExceeded: Bool

    var body: some View {
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

                if isReportTask {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Report Task To:")
                            .font(.caption)
                            .foregroundColor(.red)

                        Button(action: { showReviewerList = true }) {
                            HStack(spacing: 12) {
                                if let reviewer = selectedReviewer {
                                    ZStack {
                                        Circle().fill(Color.purple).frame(width: 28, height: 28)
                                        Text(String(reviewer.name.prefix(2)).uppercased())
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(reviewer.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text(reviewer.user_id)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
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
                    Text("Maximum 3 pinned tasks. Unpin one task first.")
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
}
