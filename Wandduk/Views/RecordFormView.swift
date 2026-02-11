import SwiftUI
import SwiftData

/// 기록지 화면 - "을지로 40년 전통의 주문서" 컨셉
struct RecordFormView: View {
    // New Record Mode: Images are passed directly
    let beforeImage: UIImage?
    let afterImage: UIImage?
    
    // Edit Mode: Existing record is passed
    let editingRecord: MealRecord?
    
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
    
    // 애니메이션 상태
    @State private var isPressingComplete = false // 버튼 누르는 중
    @State private var showImpactEffect = false // 쿵! 효과
    
    /// 저장 완료 시 루트로 돌아가기 위한 콜백
    var onSaveComplete: () -> Void = {}
    
    // 햅틱 피드백
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    
    init(beforeImage: UIImage? = nil, afterImage: UIImage? = nil, editingRecord: MealRecord? = nil, onSaveComplete: @escaping () -> Void = {}) {
        self.beforeImage = beforeImage
        self.afterImage = afterImage
        self.editingRecord = editingRecord
        self.onSaveComplete = onSaveComplete
    }
    
    var body: some View {
        ZStack {
            // 배경
            Color.brothBeige.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // 상단: 오늘의 한상
                    photoComparisonSection
                        .wabiSabi() // 살짝만 삐딱하게
                    
                    Divider()
                        .background(Color.charcoalBlack.opacity(0.2))
                        .padding(.horizontal, 24)
                    
                    // 주문서 (맛 평가)
                    orderSheetSection
                    
                    Spacer(minLength: 60)
                }
                .padding(.vertical, 24)
            }
            
            // 하단: 완뚝 불도장 버튼 (플로팅)
            VStack {
                Spacer()
                wanttukButton
            }
        }
        .navigationTitle("식사 기록")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(isSaving)
        .alert("저장 실패", isPresented: $showSaveError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
        .overlay {
            if showImpactEffect {
                impactVisualEffect
            }
        }
        .onAppear {
            if let record = editingRecord {
                selectedCategory = record.category
                memo = record.memo ?? ""
                tasteValues["saltiness"] = record.saltiness
                tasteValues["richness"] = record.richness
                tasteValues["spiciness"] = record.spiciness
                tasteValues["portion"] = record.portion
                tasteValues["sideDish"] = record.sideDish
            }
        }
    }
    
    // MARK: - Visual Sections
    
    private var photoComparisonSection: some View {
        VStack(spacing: 16) {
            Text("오늘의 한 상")
                .font(.headline)
                .foregroundStyle(Color.charcoalBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            
            HStack(spacing: 0) {
                // Before (약간 왼쪽으로 기울임)
                polaroidView(image: displayBeforeImage, label: "먹기 전")
                    .rotationEffect(.degrees(-1.5))
                    .zIndex(1)
                
                // After (약간 오른쪽으로 기울이고 겹침)
                polaroidView(image: displayAfterImage, label: "완뚝 검증")
                    .rotationEffect(.degrees(2.0))
                    .offset(x: -15)
                    .zIndex(2)
            }
        }
    }
    
    private func polaroidView(image: UIImage?, label: String) -> some View {
        VStack(spacing: 8) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .overlay(Image(systemName: "photo").foregroundStyle(.tertiary))
                }
            }
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.charcoalBlack.opacity(0.1), lineWidth: 1)
            )
            
            Text(label)
                .font(.caption)
                .fontDesign(.serif) // 명조체 느낌
                .foregroundStyle(Color.charcoalBlack.opacity(0.8))
        }
        .padding(10)
        .background(Color.white)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 2, y: 3)
    }
    
    // MARK: - Helpers
    
    private var displayBeforeImage: UIImage? {
        if let image = beforeImage { return image }
        if let record = editingRecord, let url = record.beforeImageURL {
            return UIImage(contentsOfFile: url.path)
        }
        return nil
    }

    private var displayAfterImage: UIImage? {
        if let image = afterImage { return image }
        if let record = editingRecord, let url = record.afterImageURL {
            return UIImage(contentsOfFile: url.path)
        }
        return nil
    }
    
    private var orderSheetSection: some View {
        VStack(spacing: 24) {
            // 카테고리 선택 (도장 찍기)
            categorySelector
            
            // 맛 평가 슬라이더
            VStack(spacing: 24) {
                ForEach(TasteDimension.gukbapDimensions) { dimension in
                    ArtisanTasteSlider(
                        dimension: dimension,
                        value: binding(for: dimension.id)
                    )
                }
            }
            .padding(.horizontal, 24)
            
            // 메모
            VStack(alignment: .leading, spacing: 8) {
                Text("주방장에게 한마디 (메모)")
                    .font(.subheadline)
                    .fontDesign(.serif)
                    .foregroundStyle(Color.charcoalBlack.opacity(0.7))
                
                TextField("", text: $memo, axis: .vertical)
                    .lineLimit(3...5)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.charcoalBlack.opacity(0.2), lineWidth: 1)
                            .background(Color.white.opacity(0.5))
                    )
                    .fontDesign(.serif)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var categorySelector: some View {
        HStack(spacing: 20) {
            ForEach(MealRecord.supportedCategories, id: \.self) { category in
                let isSelected = selectedCategory == category
                Button {
                    rigidImpact.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedCategory = category
                    }
                } label: {
                    Text(category)
                        .font(.headline)
                        .fontDesign(.serif)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            ZStack {
                                if isSelected {
                                    // 도장 찍힌 느낌의 불규칙한 테두리
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.kimchiRed.opacity(0.1))
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.kimchiRed, lineWidth: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.clear)
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.charcoalBlack.opacity(0.2), lineWidth: 1)
                                }
                            }
                        )
                        .foregroundStyle(isSelected ? Color.kimchiRed : Color.charcoalBlack.opacity(0.6))
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .rotationEffect(.degrees(isSelected ? -2 : 0)) // 도장은 원래 삐딱하게 찍힘
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - The "Wanttuk" Button (Heavy Impact)
    
    private var wanttukButton: some View {
        Button {
            handleWanttukPress()
        } label: {
            ZStack {
                // 1. 버튼 몸체 (솥뚜껑 이미지 에셋 - 큼직하게 유지)
                Image("SotTtukKeong")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                // 2. 텍스트 (빨간색 '완뚝' 궁서체 도장 - 솥뚜껑 대비 작게)
                Text(editingRecord != nil ? "수정" : "완뚝")
                    .font(.custom("GungSeo", size: 24)) // 32 -> 24로 줄여서 여백 확보
                    .foregroundStyle(Color.kimchiRed)
                    .shadow(color: .kimchiRed.opacity(0.5), radius: isPressingComplete ? 8 : 2)
                    .overlay(
                        // 도장 테두리
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.kimchiRed, lineWidth: 2)
                            .frame(width: 52, height: 36) // 66x46 -> 52x36로 줄임
                            .rotationEffect(.degrees(isPressingComplete ? -5 : 0))
                            .opacity(0.8)
                    )
                    .rotationEffect(.degrees(-5)) // 도장은 삐딱하게
                
                // 3. 용암 효과 (펄펄 끓음 - 로딩 중)
                if isSaving {
                    Circle()
                        .stroke(Color.lavaOrange, lineWidth: 4)
                        .frame(width: 128, height: 128)
                        .scaleEffect(1.1)
                        .opacity(0.5)
                        .overlay {
                            ProgressView()
                                .tint(.lavaOrange)
                                .scaleEffect(1.5)
                        }
                }
            }

            .scaleEffect(isPressingComplete ? 0.9 : 1.0) // 꾹 눌린 상태
        }
        .disabled(isSaving)
        .pressEvents { pressing in // 커스텀 프레스 제스처 핸들러 필요 (아래 구현)
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressingComplete = pressing
            }
        }
    }
    
    private var impactVisualEffect: some View {
        ZStack {
            // 화면 전체가 쿵 울리는 효과 (플래시)
            Color.white.opacity(0.3)
                .ignoresSafeArea()
            
            // "쿵!" 텍스트
            Text("完!")
                .font(.system(size: 100, weight: .black, design: .serif))
                .foregroundStyle(Color.charcoalBlack)
                .rotationEffect(.degrees(-10))
            
            // 충격파 원
            Circle()
                .stroke(Color.charcoalBlack, lineWidth: 5)
                .frame(width: 100, height: 100)
                .scaleEffect(2.5)
                .opacity(0)
        }
    }
    
    // MARK: - Logic
    
    private func handleWanttukPress() {
        // 1. 시각적 피드백 (쿵!)
        heavyImpact.impactOccurred()
        
        withAnimation(.easeOut(duration: 0.1)) {
            showImpactEffect = true
        }
        
        // 0.5초 뒤에 페이드아웃 및 저장 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showImpactEffect = false
            }
            Task {
                await saveRecord()
            }
        }
    }
    
    private func binding(for id: String) -> Binding<Int> {
        Binding(
            get: { tasteValues[id] ?? 4 },
            set: { tasteValues[id] = $0 }
        )
    }
    
    private func saveRecord() async {
        isSaving = true
        
        // Edit Mode
        if let record = editingRecord {
            record.category = selectedCategory
            record.memo = memo.isEmpty ? nil : memo
            record.saltiness = tasteValues["saltiness"] ?? 4
            record.richness = tasteValues["richness"] ?? 4
            record.spiciness = tasteValues["spiciness"] ?? 4
            record.portion = tasteValues["portion"] ?? 4
            record.sideDish = tasteValues["sideDish"] ?? 4
            
            // TODO: 이미지 수정 기능이 필요하다면 여기서 처리
            
            await MainActor.run {
                // SwiftData 컨텍스트 저장 (자동 처리되지만 명시적 호출 가능)
                try? modelContext.save()
                isSaving = false
                onSaveComplete()
                dismiss() // 시트 닫기
            }
            return
        }
        
        // Create Mode
        do {
            guard let before = beforeImage, let after = afterImage else { return }
            
            let beforePath = try ImageStorageService.saveImage(before)
            let afterPath = try ImageStorageService.saveImage(after)
            
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
            
            await MainActor.run {
                modelContext.insert(record)
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

// MARK: - Artisan Taste Slider

struct ArtisanTasteSlider: View {
    let dimension: TasteDimension
    @Binding var value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(dimension.name)
                    .font(.body)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.charcoalBlack)
                
                Spacer()
                
                Text(dimension.feedback(for: value))
                    .font(.caption)
                    .fontDesign(.serif)
                    .foregroundStyle(Color.charcoalBlack.opacity(0.6))
            }
            
            // 커스텀 슬라이더 트랙
            GeometryReader { geo in
                let width = geo.size.width
                let step = width / 6
                
                ZStack(alignment: .leading) {
                    // 트랙 (붓터치 느낌의 선)
                    Rectangle()
                        .fill(Color.charcoalBlack.opacity(0.1))
                        .frame(height: 2)
                    
                    // 눈금 (손으로 찍은 점)
                    HStack(spacing: 0) {
                        ForEach(0..<7) { i in
                            Circle()
                                .fill(Color.charcoalBlack.opacity(i < value ? 0.8 : 0.2))
                                .frame(width: 4, height: 4)
                            if i < 6 { Spacer() }
                        }
                    }
                    
                    // 썸 (재료 - 고추, 소금 등)
                    Text(dimension.icon) // 이모지를 재료로 사용
                        .font(.system(size: 24))
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                        .position(x: CGFloat(value - 1) * step, y: 10) // 중앙 정렬 보정
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let percent = min(max(value.location.x / width, 0), 1)
                            let newValue = Int(round(percent * 6)) + 1
                            if self.value != newValue {
                                UISelectionFeedbackGenerator().selectionChanged()
                                self.value = newValue
                            }
                        }
                )
            }
            .frame(height: 30)
        }
    }
}

// MARK: - Press Actions Modifier

extension View {
    func pressEvents(onPress: @escaping (Bool) -> Void) -> some View {
        buttonStyle(PressButtonStyle(onPress: onPress))
    }
}

struct PressButtonStyle: ButtonStyle {
    var onPress: (Bool) -> Void
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                onPress(newValue)
            }
    }
}

#Preview {
    RecordFormView(
        beforeImage: UIImage(),
        afterImage: UIImage()
    )
}
