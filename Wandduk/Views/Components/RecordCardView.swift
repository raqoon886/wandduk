import SwiftUI

struct RecordCardView: View {
    let record: MealRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 썸네일
            Group {
                if let image = ImageStorageService.loadImage(at: record.beforeImagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 160)
                }
            }
            
            // 정보 (종이 질감 하단)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(record.category).font(.headline).fontDesign(.serif)
                    Spacer()
                    Text(record.categoryEmoji)
                }
                
                Text(record.createdAt, format: .dateTime.month().day())
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color.charcoalBlack.opacity(0.6))
            }
            .padding(12)
            .background(Color.white)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 4)) // 둥근 모서리 대신 각지게
        .shadow(color: .black.opacity(0.1), radius: 3, x: 2, y: 2) // 종이 그림자
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.charcoalBlack.opacity(0.05), lineWidth: 1)
        )
    }
}
