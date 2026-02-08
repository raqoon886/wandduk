import Foundation

/// 맛 평가 항목 정의
struct TasteDimension: Identifiable {
    let id: String
    let icon: String
    let name: String
    let leftLabel: String
    let centerLabel: String
    let rightLabel: String
    
    /// 7점 척도에 따른 피드백 멘트
    func feedback(for value: Int) -> String {
        switch value {
        case 1: return leftLabel
        case 2: return "조금 \(leftLabel)"
        case 3: return "살짝 \(leftLabel)"
        case 4: return centerLabel
        case 5: return "살짝 \(rightLabel)"
        case 6: return "조금 \(rightLabel)"
        case 7: return rightLabel
        default: return centerLabel
        }
    }
}

// MARK: - 국밥 전용 평가 항목
extension TasteDimension {
    static let gukbapDimensions: [TasteDimension] = [
        TasteDimension(
            id: "saltiness",
            icon: "🧂",
            name: "간 (염도)",
            leftLabel: "싱거워요",
            centerLabel: "딱 좋아요!",
            rightLabel: "짭짤해요"
        ),
        TasteDimension(
            id: "richness",
            icon: "🍲",
            name: "국물 농도",
            leftLabel: "맑아요",
            centerLabel: "적당해요",
            rightLabel: "진해요"
        ),
        TasteDimension(
            id: "spiciness",
            icon: "🌶️",
            name: "맵기",
            leftLabel: "순해요",
            centerLabel: "얼큰해요",
            rightLabel: "매워요"
        ),
        TasteDimension(
            id: "portion",
            icon: "🥩",
            name: "건더기 양",
            leftLabel: "아쉬워요",
            centerLabel: "든든해요",
            rightLabel: "푸짐해요"
        ),
        TasteDimension(
            id: "sideDish",
            icon: "🥬",
            name: "김치/깍두기",
            leftLabel: "평범해요",
            centerLabel: "맛있어요",
            rightLabel: "국밥도둑!"
        )
    ]
}
