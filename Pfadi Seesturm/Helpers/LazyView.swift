//
//  LazyView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 12.12.2024.
//

import SwiftUI

struct LazyView<Content: View>: View {
    
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
    
}
