//
//  ErrorView.swift
//  News
//
//  Created by Ярослав Куприянов on 28.10.2023.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    var title: String
    var action: Action?
    
    @State private var animating = false
    @State private var scale = 0
    
    private var titleLabel: some View {
        VStack {
            Label(title, systemImage: "bolt.fill")
                .labelStyle(.titleOnly)
                .fontDesign(.monospaced)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(EdgeInsets(top: .zero,
                                    leading: 100,
                                    bottom: .zero,
                                    trailing: 100))
            
            Image("errorCat")
                .resizable()
                .imageScale(.small)
                .frame(width: 90, height: 100)
        }
    }
    
    private var button: some View {
        Button(action: {
            VibrateManager.shared.impactOccured(.rigid)
            action?()
        }, label: {
            Text("Reload")
                .fontDesign(.monospaced)
                .foregroundStyle(.gray)
        })
        .buttonStyle(.bordered)
        .clipShape(.capsule(style: .circular))
        .controlSize(.large)
    }
    
    var body: some View {
        ZStack {
            VStack {
                titleLabel
                button
            }
        }
        .opacity(animating ? 1 : 0)
        .scaleEffect(animating ? 1 : 0)
        .animation(.bouncy(duration: 0.3,
                           extraBounce: 0.2),
                   value: animating)
        .onAppear { animating = true }
    }
}

#Preview {
    ErrorView(title: "Time - out\nerror\n\nServer problem or internet connection broken",
              action: {
        print("Button pressed")
    })
}
