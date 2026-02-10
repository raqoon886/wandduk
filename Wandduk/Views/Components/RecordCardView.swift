import SwiftUI

/// 아카이브 그리드에 표시되는 기록 카드
struct RecordCardView: View {
    let record: MealRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 썸네일 이미지
            Group {
                if let image = ImageStorageService.loadImage(at: record.beforeImagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundStyle(.tertiary)
                        }
                }
            }
            .frame(height: 160)
            .clipped()
            
            // 하단 정보
            VStack(alignment: .leading, spacing: 4) {
                // 카테고리 + 이모지
                HStack(spacing: 4) {
                    Text(record.categoryEmoji)
                        .font(.caption)
                    Text(record.category)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // 날짜
                Text(record.createdAt, format: .dateTime.month().day().weekday())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
}

#Preview {
    RecordCardView(record: MealRecord(
        category: "국밥",
        beforeImagePath: "",
        afterImagePath: ""
    ))
    .frame(width: 170)
    .padding()
}
