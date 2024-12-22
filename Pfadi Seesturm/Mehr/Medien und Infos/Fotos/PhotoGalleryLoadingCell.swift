//
//  PhotoGalleryLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct PhotoGalleryLoadingCell: View {
    
    var width: CGFloat
    var height: CGFloat
    var withText: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(Color.skeletonPlaceholderColor)
                .frame(width: width, height: height)
                .cornerRadius(3)
                .customLoadingBlinking()
            if withText {
                Text(Constants.PLACEHOLDER_TEXT)
                    .frame(width: width)
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
                    .customLoadingBlinking()
            }
        }
        .padding(0)
    }
}

#Preview("With text") {
    PhotoGalleryLoadingCell(
        width: 150, height: 150, withText: true
    )
}
#Preview("Without text") {
    PhotoGalleryLoadingCell(
        width: 150, height: 150, withText: false
    )
}
