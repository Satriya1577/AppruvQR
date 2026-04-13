//
//  HeaderTaskSheetView.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 13/04/26.
//

import SwiftUI

struct HeaderTaskSheetView: View {
    let title: String
    let isSaveEnabled: Bool
    let onClose: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer()

            Text(title)
                .font(.headline)

            Spacer()

            Button(action: onSave) {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(isSaveEnabled ? Color.blue : Color.gray)
                    .clipShape(Circle())
            }
            .disabled(!isSaveEnabled)
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}
