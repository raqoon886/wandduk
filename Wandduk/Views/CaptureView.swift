import SwiftUI
import PhotosUI

struct CaptureView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var dismissToRoot: Bool
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private let mockService = MockPhotoCaptureService()
    
    @State private var currentStep: CaptureType = .before
    @State private var beforeImage: UIImage?
    @State private var afterImage: UIImage?
    @State private var isCapturing = false
    @State private var showCamera = false
    @State private var showRecordForm = false
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경: 검은색 (카메라 뷰파인더 느낌)
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 단계 표시
                    stepIndicator
                        .padding(.top, 16)
                    
                    Spacer()
                    
                    // 뷰파인더 영역
                    viewFinder
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // 셔터 버튼
                    // 하단 컨트롤 (갤러리 + 셔터)
                    HStack(spacing: 40) {
                        // 갤러리 버튼
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.charcoalBlack.opacity(0.6))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // 셔터 버튼
                        shutterButton
                        
                        // 균형을 위한 더미 (또는 추후 플래시 버튼 등)
                        Color.clear
                            .frame(width: 50, height: 50)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showCamera) {
                CameraPickerView { image in
                    handleImageCaptured(image)
                }
            }
            .navigationDestination(isPresented: $showRecordForm) {
                if let before = beforeImage {
                    // afterImage can be nil
                    RecordFormView(beforeImage: before, afterImage: afterImage) {
                        dismissToRoot = false
                    }
                }
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            handleImageCaptured(image)
                            selectedPhoto = nil // 리셋
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            Text(currentStep == .before ? "식사 전" : "완뚝 인증")
                .font(.headline)
                .fontDesign(.serif)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.charcoalBlack.opacity(0.6))
                        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                )
        }
    }
    
    private var viewFinder: some View {
        GeometryReader { geo in
            ZStack {
                if let image = currentImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    // 빈 화면: 그리드 표시
                    Color.black.opacity(0.5)
                    gridLines
                }
                
                // 김 서림 효과 (Steaming Effect) - After 단계일 때
                if currentStep == .after {
                    steamingOverlay
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4)) // 약간 각진 느낌
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var gridLines: some View {
        ZStack {
            HStack {
                Spacer(); Divider().background(.white.opacity(0.2)); Spacer(); Divider().background(.white.opacity(0.2)); Spacer()
            }
            VStack {
                Spacer(); Divider().background(.white.opacity(0.2)); Spacer(); Divider().background(.white.opacity(0.2)); Spacer()
            }
        }
    }
    
    private var steamingOverlay: some View {
        // 김 서림: 가장자리가 뿌옇게, 약간의 노이즈
        ZStack {
            RadialGradient(
                colors: [.clear, .white.opacity(0.15)],
                center: .center,
                startRadius: 50,
                endRadius: 200
            )
            .blendMode(.screen)
        }
    }
    
    private var shutterButton: some View {
        Button {
             capturePhoto()
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(currentStep == .before ? Color.white : Color.lavaOrange)
                    .frame(width: 70, height: 70)
                    .scaleEffect(isCapturing ? 0.9 : 1.0)
            }
        }
        .disabled(isCapturing)
        .overlay(alignment: .trailing) {
            // 다음 단계 버튼
            if currentImage != nil {
                Button {
                    proceedToNextStep()
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.lavaOrange)
                        .clipShape(Circle())
                }
                .offset(x: 80)
                // 건너뛰기 버튼 (이미지가 없을 때)
                Button {
                    proceedToNextStep()
                } label: {
                    Text("건너뛰기")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: true, vertical: false) // 텍스트 줄바꿈 방지
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.charcoalBlack.opacity(0.6))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .offset(y: -80) // 셔터 버튼 위쪽
            }
        }
    }
    
    // MARK: - Logic
    
    private var currentImage: UIImage? {
        currentStep == .before ? beforeImage : afterImage
    }
    
    private func capturePhoto() {
        if isSimulator {
            isCapturing = true
            Task {
                let image = await mockService.capturePhoto(type: currentStep)
                await MainActor.run {
                    handleImageCaptured(image)
                }
            }
        } else {
            showCamera = true
        }
    }
    
    private func handleImageCaptured(_ image: UIImage?) {
        withAnimation {
            if currentStep == .before {
                beforeImage = image
            } else {
                afterImage = image
            }
            isCapturing = false
        }
    }
    
    private func proceedToNextStep() {
        if currentStep == .before {
            withAnimation { currentStep = .after }
        } else {
            showRecordForm = true
        }
    }
}

#Preview {
    NavigationStack {
        CaptureView(dismissToRoot: .constant(true))
    }
}
