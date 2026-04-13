//
//  ReflectionBackButtonView.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 08/04/26.
//

import SwiftUI

struct ReflectionBackButtonView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
