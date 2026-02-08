import SwiftUI

/// 기록지 화면 - Before/After 사진과 맛 평가
struct RecordFormView: View {
    let beforeImage: UIImage
    let afterImage: UIImage
    
    @Environment(\.dismiss) private var dismiss
    
    // 맛 평가 값 (1~7, 기본값 4)
    @State private var tasteValues: [String: Int] = [
        "saltiness": 4,
        "richness": 4,
        "spiciness": 4,
        "portion": 4,
        "sideDish": 4
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Before/After 사진 비교
                photoComparisonSection
                
                Divider()
                    .padding(.horizontal)
                
                // 맛 평가 섹션
                tasteEvaluationSection
                
                // 저장 버튼
                saveButton
                    .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .navigationTitle("기록하기")
        .navigationBarTitleDisplayMode(.inline)
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
    
    private var saveButton: some View {
        Button {
            // TODO: 저장 로직
            dismiss()
        } label: {
            Text("기록 완료")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.gradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private func binding(for id: String) -> Binding<Int> {
        Binding(
            get: { tasteValues[id] ?? 4 },
            set: { tasteValues[id] = $0 }
        )
    }
}

#Preview {
    NavigationStack {
        RecordFormView(
            beforeImage: UIImage(named: "SampleGukbap") ?? UIImage(),
            afterImage: UIImage(named: "SampleRamen") ?? UIImage()
        )
    }
}
