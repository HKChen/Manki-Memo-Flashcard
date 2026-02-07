//
//  CardStore.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/20.
//

import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class CardStore {
    var cards: [FlashCard] = []
    var categories: [Category] = []

    private let saveKey = "ManikiMemoFlashCards"
    private let categorySaveKey = "ManikiMemoCategories"

    init() {
        loadCards()
        loadCategories()
    }

    // MARK: - Cards

    func addCard(_ card: FlashCard) {
        cards.insert(card, at: 0)
        saveCards()
    }

    func deleteCard(_ card: FlashCard) {
        cards.removeAll { $0.id == card.id }
        saveCards()
    }

    func deleteCards(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        saveCards()
    }

    func updateCard(_ card: FlashCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
            saveCards()
        }
    }

    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadCards() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([FlashCard].self, from: data) {
            cards = decoded
        }
    }

    // MARK: - Categories

    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }

    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }

    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        // Optional: Remove this category from all cards
        for index in cards.indices {
            cards[index].categoryIDs.removeAll { $0 == category.id }
        }
        saveCards()
        saveCategories()
    }

    func deleteCategories(at offsets: IndexSet) {
        let categoriesToDelete = offsets.map { categories[$0] }
        categories.remove(atOffsets: offsets)

        // Remove deleted categories from all cards
        for category in categoriesToDelete {
            for index in cards.indices {
                cards[index].categoryIDs.removeAll { $0 == category.id }
            }
        }
        saveCards()
        saveCategories()
    }

    func categories(for card: FlashCard) -> [Category] {
        return categories.filter { card.categoryIDs.contains($0.id) }
    }

    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categorySaveKey)
        }
    }

    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: categorySaveKey),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        }
    }
}
