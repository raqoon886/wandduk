import SwiftUI
import SwiftData

struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let record: MealRecord
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 영수증/메뉴판 컨셉의 카드
                VStack(spacing: 24) {
                    // 상단 사진
                    HStack(spacing: 12) {
                        polaroid(imagePath: record.beforeImagePath)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.charcoalBlack.opacity(0.5))
                        polaroid(imagePath: record.afterImagePath)
                    }
                    
                    Divider().background(Color.charcoalBlack.opacity(0.2))
                    
                    // 맛 평가 도트
                    tasteResultSection
                    
                    if let memo = record.memo {
                        Divider().background(Color.charcoalBlack.opacity(0.2))
                        Text(memo)
                            .font(.body)
                            .fontDesign(.serif)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    
                    // 날짜 스탬프
                    HStack {
                        Spacer()
                        Text(record.createdAt, format: .dateTime.year().month().day())
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color.charcoalBlack.opacity(0.6))
                    }
                }
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 2)) // 각진 영수증 느낌
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                .padding(20)
                
                // 삭제 버튼
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("기록 태우기 (삭제)")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                        .padding()
                }
            }
            .padding(.top, 20)
        }
        .background(Color.brothBeige.ignoresSafeArea())
        .navigationTitle(record.category)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("삭제", isPresented: $showDeleteConfirmation) {
            Button("삭제", role: .destructive) { deleteRecord() }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("수정") {
                    showEditSheet = true
                }
            }
        }
        .fullScreenCover(isPresented: $showEditSheet) {
            NavigationStack {
                RecordFormView(editingRecord: record)
            }
        }
    }
    
    private func polaroid(imagePath: String) -> some View {
        Group {
            if let image = ImageStorageService.loadImage(at: imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle().fill(Color.gray.opacity(0.2))
            }
        }
        .frame(width: 100, height: 100)
        .border(Color.charcoalBlack.opacity(0.1), width: 1)
    }
    
    private var tasteResultSection: some View {
        VStack(spacing: 12) {
            ForEach(TasteDimension.gukbapDimensions) { dim in
                let value = getValue(for: dim.id)
                HStack {
                    Text(dim.name).font(.caption).bold().foregroundStyle(Color.charcoalBlack)
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<7) { i in
                            Circle()
                                .fill(i < value ? Color.lavaOrange : Color.gray.opacity(0.1))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }
        }
    }
    
    private func getValue(for id: String) -> Int {
        switch id {
        case "saltiness": return record.saltiness
        case "richness": return record.richness
        case "spiciness": return record.spiciness
        case "portion": return record.portion
        case "sideDish": return record.sideDish
        default: return 0
        }
    }
    
    private func deleteRecord() {
        ImageStorageService.deleteImage(at: record.beforeImagePath)
        ImageStorageService.deleteImage(at: record.afterImagePath)
        modelContext.delete(record)
        dismiss()
    }
}
