//
//  StampStatView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 09/04/2026.
//

import SwiftUI

struct StampStatView: View {
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Star shape
                StarShape()
                    .fill(AppTheme.Colour.backgroundWarm)
                StarShape()
                    .stroke(Color(hex: "5A1828"), lineWidth: 1.5)

                VStack(spacing: 1) {
                    Text("\(count)")
                        .font(AppTheme.Font.displaySmall)
                        .foregroundStyle(AppTheme.Colour.inkDark)
                    
                }
            }
            .frame(width: 72, height: 72)

            Text(label)
                .font(AppTheme.Font.handwritingSmall)
                .foregroundStyle(AppTheme.Colour.inkLight)
        }
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.45
        let points = 5
        var path = Path()

        for i in 0..<points * 2 {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
