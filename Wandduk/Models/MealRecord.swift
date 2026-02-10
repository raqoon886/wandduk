import Foundation
import SwiftData

/// 완뚝 기록 — 한 그릇 음식의 Before/After 사진과 맛 평가를 저장
@Model
final class MealRecord {
    var id: UUID
    var createdAt: Date
    
    /// 음식 카테고리 (예: "국밥", "라멘")
    var category: String
    
    /// 이미지 파일 경로 (Documents 디렉토리 기준 상대 경로)
    var beforeImagePath: String
    var afterImagePath: String
    
    // MARK: - 맛 평가 (1~7, 기본값 4)
    var saltiness: Int
    var richness: Int
    var spiciness: Int
    var portion: Int
    var sideDish: Int
    
    /// 자유 메모
    var memo: String?
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: String,
        beforeImagePath: String,
        afterImagePath: String,
        saltiness: Int = 4,
        richness: Int = 4,
        spiciness: Int = 4,
        portion: Int = 4,
        sideDish: Int = 4,
        memo: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.beforeImagePath = beforeImagePath
        self.afterImagePath = afterImagePath
        self.saltiness = saltiness
        self.richness = richness
        self.spiciness = spiciness
        self.portion = portion
        self.sideDish = sideDish
        self.memo = memo
    }
}

// MARK: - Helpers

extension MealRecord {
    /// 카테고리별 이모지
    var categoryEmoji: String {
        switch category {
        case "국밥": return "🍲"
        case "라멘": return "🍜"
        default: return "🍽️"
        }
    }
    
    /// 지원되는 카테고리 목록
    static let supportedCategories = ["국밥", "라멘"]
    
    /// Before 이미지의 절대 경로 URL
    var beforeImageURL: URL? {
        ImageStorageService.fullURL(for: beforeImagePath)
    }
    
    /// After 이미지의 절대 경로 URL
    var afterImageURL: URL? {
        ImageStorageService.fullURL(for: afterImagePath)
    }
}
