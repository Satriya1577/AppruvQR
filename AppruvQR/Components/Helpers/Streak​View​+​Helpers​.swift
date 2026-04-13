//
//  StreakView+Helpers.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 13/04/26.
//

import SwiftUI

extension StreakView {
    var faceImageName: String {
        let health = currentUser?.streakHealthCount ?? 3
        
        switch health {
        case 3:
            return "EmoticonFull"
        case 2:
            return "EmoticonWarning"
        case 1, 0:
            return "EmoticonEnd"
        default:
            return "EmoticonFull"
        }
    }
}

private struct StreakOutlineModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: -offset, y: -offset)
            .shadow(color: color, radius: radius, x: offset, y: offset)
            .shadow(color: color, radius: radius, x: -offset, y: offset)
            .shadow(color: color, radius: radius, x: offset, y: -offset)
    }
}

extension View {
    func streakOutline(color: Color, radius: CGFloat = 1, offset: CGFloat = 2) -> some View {
        modifier(StreakOutlineModifier(color: color, radius: radius, offset: offset))
    }
}

