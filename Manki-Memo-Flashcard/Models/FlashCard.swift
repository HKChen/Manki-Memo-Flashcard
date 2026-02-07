//
//  FlashCard.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/20.
//

import Foundation

struct FlashCard: Identifiable, Codable, Equatable {
    var id: UUID
    var japanese: String
    var translation: String
    var notes: String
    var categoryIDs: [UUID]
    var createdAt: Date

    init(id: UUID = UUID(), japanese: String, translation: String, notes: String = "", categoryIDs: [UUID] = [], createdAt: Date = Date()) {
        self.id = id
        self.japanese = japanese
        self.translation = translation
        self.notes = notes
        self.categoryIDs = categoryIDs
        self.createdAt = createdAt
    }
}
