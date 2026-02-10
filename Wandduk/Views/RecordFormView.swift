import SwiftUI
import SwiftData

/// 기록지 화면 - Before/After 사진과 맛 평가
struct RecordFormView: View {
    let beforeImage: UIImage
    let afterImage: UIImage
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 맛 평가 값 (1~7, 기본값 4)
    @State private var tasteValues: [String: Int] = [
        "saltiness": 4,
        "richness": 4,
        "spiciness": 4,
        "portion": 4,
        "sideDish": 4
    ]
    
    // 카테고리 선택
    @State private var selectedCategory: String = "국밥"
    
    // 메모
    @State private var memo: String = ""
    
    // 저장 상태
    @State private var isSaving = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""
    
    /// 저장 완료 시 루트로 돌아가기 위한 콜백
    var onSaveComplete: () -> Void = {}
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Before/After 사진 비교
                photoComparisonSection
                
                Divider()
                    .padding(.horizontal)
                
                // 카테고리 선택
                categorySection
                
                Divider()
                    .padding(.horizontal)
                
                // 맛 평가 섹션
                tasteEvaluationSection
                
                Divider()
                    .padding(.horizontal)
                
                // 메모 입력
                memoSection
                
                // 저장 버튼
                saveButton
                    .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .navigationTitle("기록하기")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(isSaving)
        .alert("저장 실패", isPresented: $showSaveError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
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
                // Before
                photoCard(image: beforeImage, label: "식사 전")
                
                // Arrow
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                // After
                photoCard(image: afterImage, label: "완뚝!")
            }
            .padding(.horizontal)
        }
    }
    
    private func photoCard(image: UIImage, label: String) -> some View {
        VStack(spacing: 8) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var categorySection: some View {
        VStack(spacing: 12) {
            Text("카테고리")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 10) {
                ForEach(MealRecord.supportedCategories, id: \.self) { category in
                    let emoji = category == "국밥" ? "🍲" : "🍜"
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(emoji)
                            Text(category)
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            selectedCategory == category
                                ? Color.orange.opacity(0.15)
                                : Color.gray.opacity(0.08)
                        )
                        .foregroundStyle(
                            selectedCategory == category ? .orange : .primary
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedCategory == category ? Color.orange : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var tasteEvaluationSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("맛 평가")
                    .font(.headline)
                
                Spacer()
                
                // 리셋 버튼
                Button {
                    withAnimation {
                        for key in tasteValues.keys {
                            tasteValues[key] = 4
                        }
                    }
                } label: {
                    Label("초기화", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            // 맛 슬라이더들
            VStack(spacing: 4) {
                ForEach(TasteDimension.gukbapDimensions) { dimension in
                    TasteSlider(
                        dimension: dimension,
                        value: binding(for: dimension.id)
                    )
                    
                    if dimension.id != TasteDimension.gukbapDimensions.last?.id {
                        Divider()
                            .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    private var memoSection: some View {
        VStack(spacing: 8) {
            Text("메모 (선택)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            TextField("오늘의 한 줄 감상을 남겨보세요", text: $memo, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(3...6)
                .padding()
                .background(Color.gray.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        }
    }
    
    private var saveButton: some View {
        Button {
            Task {
                await saveRecord()
            }
        } label: {
            Group {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("기록 완료")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isSaving)
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private func binding(for id: String) -> Binding<Int> {
        Binding(
            get: { tasteValues[id] ?? 4 },
            set: { tasteValues[id] = $0 }
        )
    }
    
    // MARK: - Save Logic
    
    private func saveRecord() async {
        isSaving = true
        
        do {
            // 1. 이미지 파일 저장
            let beforePath = try ImageStorageService.saveImage(beforeImage)
            let afterPath = try ImageStorageService.saveImage(afterImage)
            
            // 2. MealRecord 생성
            let record = MealRecord(
                category: selectedCategory,
                beforeImagePath: beforePath,
                afterImagePath: afterPath,
                saltiness: tasteValues["saltiness"] ?? 4,
                richness: tasteValues["richness"] ?? 4,
                spiciness: tasteValues["spiciness"] ?? 4,
                portion: tasteValues["portion"] ?? 4,
                sideDish: tasteValues["sideDish"] ?? 4,
                memo: memo.isEmpty ? nil : memo
            )
            
            // 3. SwiftData에 저장
            await MainActor.run {
                modelContext.insert(record)
            }
            
            // 4. 저장 완료 → 루트(아카이브)로 복귀
            await MainActor.run {
                isSaving = false
                onSaveComplete()
            }
        } catch {
            await MainActor.run {
                isSaving = false
                saveErrorMessage = error.localizedDescription
                showSaveError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecordFormView(
            beforeImage: UIImage(named: "SampleGukbap") ?? UIImage(),
            afterImage: UIImage(named: "SampleRamen") ?? UIImage()
        )
    }
    .modelContainer(for: MealRecord.self, inMemory: true)
}
