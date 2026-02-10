import SwiftUI
import SwiftData

/// 저장된 기록 상세 조회 화면
struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let record: MealRecord
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Before / After 사진 비교
                photoComparisonSection
                
                Divider()
                    .padding(.horizontal)
                
                // 맛 평가 결과
                tasteResultSection
                
                // 메모
                if let memo = record.memo, !memo.isEmpty {
                    memoSection(memo)
                }
                
                // 삭제 버튼
                deleteButton
                    .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .navigationTitle("\(record.categoryEmoji) \(record.category)")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("이 기록을 삭제할까요?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                deleteRecord()
            }
            Button("취소", role: .cancel) {}
        }
    }
    
    // MARK: - Subviews
    
    private var photoComparisonSection: some View {
        VStack(spacing: 12) {
            Text("오늘의 한 그릇")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                photoCard(imagePath: record.beforeImagePath, label: "식사 전")
                
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                photoCard(imagePath: record.afterImagePath, label: "완뚝!")
            }
            .padding(.horizontal)
            
            // 날짜 정보
            Text(record.createdAt, format: .dateTime.year().month().day().weekday().hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
    
    private func photoCard(imagePath: String, label: String) -> some View {
        VStack(spacing: 8) {
            Group {
                if let image = ImageStorageService.loadImage(at: imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.tertiary)
                        }
                }
            }
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var tasteResultSection: some View {
        VStack(spacing: 8) {
            Text("맛 평가")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(Array(tasteResults.enumerated()), id: \.offset) { index, result in
                    HStack {
                        Text(result.icon)
                            .font(.title3)
                        Text(result.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // 값 표시 (점 그래프)
                        HStack(spacing: 4) {
                            ForEach(1...7, id: \.self) { step in
                                Circle()
                                    .fill(step <= result.value ? Color.orange : Color.gray.opacity(0.2))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Text(result.feedback)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 70, alignment: .trailing)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    
                    if index < tasteResults.count - 1 {
                        Divider()
                    }
                }
            }
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    private func memoSection(_ memo: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("메모")
                .font(.headline)
                .padding(.horizontal)
            
            Text(memo)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("기록 삭제", systemImage: "trash")
                .font(.subheadline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Data
    
    private struct TasteResult {
        let icon: String
        let name: String
        let value: Int
        let feedback: String
    }
    
    private var tasteResults: [TasteResult] {
        let dimensions = TasteDimension.gukbapDimensions
        let values = [record.saltiness, record.richness, record.spiciness, record.portion, record.sideDish]
        
        return zip(dimensions, values).map { dimension, value in
            TasteResult(
                icon: dimension.icon,
                name: dimension.name,
                value: value,
                feedback: dimension.feedback(for: value)
            )
        }
    }
    
    // MARK: - Actions
    
    private func deleteRecord() {
        // 이미지 파일 삭제
        ImageStorageService.deleteImage(at: record.beforeImagePath)
        ImageStorageService.deleteImage(at: record.afterImagePath)
        
        // DB에서 삭제
        modelContext.delete(record)
        
        dismiss()
    }
}

#Preview {
    NavigationStack {
        RecordDetailView(record: MealRecord(
            category: "국밥",
            beforeImagePath: "",
            afterImagePath: "",
            saltiness: 5,
            richness: 6,
            spiciness: 3,
            portion: 4,
            sideDish: 7,
            memo: "이 집 국밥은 정말 맛있었다!"
        ))
    }
}
