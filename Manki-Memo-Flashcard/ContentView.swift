//
//  ContentView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/20.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            TabView(selection: $selection) {
                CardListView()
                    .tabItem {
                        Label("字卡", systemImage: "rectangle.stack.fill")
                    }
                    .tag(0)

                AddCardView(tabSelection: $selection)
                    .tabItem {
                        Label("新增", systemImage: "plus.circle.fill")
                    }
                    .tag(1)

                CategoryListView()
                    .tabItem {
                        Label("分類", systemImage: "tray.full.fill")
                    }
                    .tag(2)

                StudySetupView()
                    .tabItem {
                        Label("抽卡", systemImage: "play.rectangle.fill")
                    }
                    .tag(3)
            }
            .tint(AppTheme.Colors.accent)
        }
    }
}

#Preview {
    ContentView()
        .environment(CardStore())
}
