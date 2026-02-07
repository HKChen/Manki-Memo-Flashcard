//
//  Manki_Memo_FlashcardApp.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/25.
//

import SwiftUI

@main
struct Manki_Memo_FlashcardApp: App {
    @State private var cardStore = CardStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(cardStore)
        }
    }
}
