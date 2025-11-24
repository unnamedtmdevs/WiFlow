//
//  ContentView.swift
//  VentureFlow
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isBlock") private var isBlock: Bool = true

    var body: some View {
        if isBlock {
            WebSystem()
        } else {
            MainContainerView()
        }
    }
}

#Preview {
    ContentView()
}
