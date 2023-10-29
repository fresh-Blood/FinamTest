//
//  CategoryView.swift
//  News
//
//  Created by Ярослав Куприянов on 29.10.2023.
//

import Foundation
import SwiftUI

typealias CategoryAction = (String) -> ()

struct CategoryView: View {
    @State private var animating = false
    
    private let categories = Categories.allCases
    
    var action: CategoryAction?
    
    var body: some View {
        List {
            Section {
                ForEach(categories) { category in
                    CategoryCell(category: category.rawValue.capitalized)
                        .onTapGesture {
                            VibrateManager.shared.impactOccured(.rigid)
                            action?(category.rawValue.lowercased())
                        }
                }
            }
        }
        .backgroundStyle(.background)
        .listStyle(.sidebar)
        .scrollDisabled(true)
        .opacity(animating ? 1 : 0)
        .scaleEffect(animating ? 1 : 0)
        .animation(.bouncy(duration: 0.2, extraBounce: 0),
                   value: animating)
        .onAppear { animating = true }
    }
}

struct CategoryCell: View {
    let category: String
    
    var image: String {
        switch category {
            case Categories.technology.rawValue.capitalized:
                return "iphone.gen1.radiowaves.left.and.right"
            case Categories.sports.rawValue.capitalized:
                return "figure.outdoor.cycle"
            case Categories.science.rawValue.capitalized:
                return "atom"
            case Categories.health.rawValue.capitalized:
                return "bolt.heart"
            case Categories.general.rawValue.capitalized:
                return "list.clipboard"
            case Categories.entertainment.rawValue.capitalized:
                return "play"
            case Categories.business.rawValue.capitalized:
                return "brain.filled.head.profile"
            default:
                return "gear"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: image)
            Text(category)
                .font(.system(size: 18, weight: .regular))
        }
        .frame(height: 45)
    }
}

#if DEBUG
#Preview {
    CategoryView()
}
#endif
