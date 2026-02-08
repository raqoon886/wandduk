import SwiftUI

/// 촬영 화면 - Before/After 2단계 촬영 플로우
struct CaptureView: View {
    @Environment(\.dismiss) private var dismiss
    
    /// 촬영 서비스 (Mock 또는 Real)
    private let captureService: PhotoCaptureProtocol
    
    /// 현재 촬영 단계
    @State private var currentStep: CaptureType = .before
    
    /// 촬영된 이미지
    @State private var beforeImage: UIImage?
    @State private var afterImage: UIImage?
    
    /// 촬영 중 로딩 상태
    @State private var isCapturing = false
    
    /// 기록지 화면으로 이동
    @State private var showRecordForm = false
    
    init(captureService: PhotoCaptureProtocol = MockPhotoCaptureService()) {
        self.captureService = captureService
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단: 단계 인디케이터
            stepIndicator
                .padding(.top, 8)
            
            // 중앙: 프리뷰 영역
            previewArea
            
            // 하단: 촬영 버튼
            captureButton
                .padding(.bottom, 40)
        }
        .navigationTitle(currentStep.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(currentStep == .after && beforeImage != nil)
        .toolbar {
            if currentStep == .after && beforeImage != nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("이전") {
                        withAnimation {
                            currentStep = .before
                            afterImage = nil
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showRecordForm) {
            if let before = beforeImage, let after = afterImage {
                RecordFormView(beforeImage: before, afterImage: after)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            stepDot(for: .before)
            Rectangle()
                .fill(afterImage != nil ? Color.orange : Color.gray.opacity(0.3))
                .frame(width: 40, height: 2)
            stepDot(for: .after)
        }
        .padding(.vertical, 16)
    }
    
    private func stepDot(for step: CaptureType) -> some View {
        let isCompleted = (step == .before && beforeImage != nil) || (step == .after && afterImage != nil)
        let isCurrent = step == currentStep
        
        return Circle()
            .fill(isCompleted ? Color.orange : (isCurrent ? Color.orange.opacity(0.5) : Color.gray.opacity(0.3)))
            .frame(width: 12, height: 12)
            .overlay {
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
    }
    
    private var previewArea: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.05))
                
                // 촬영된 이미지 또는 플레이스홀더
                if let image = currentImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width - 32, height: geometry.size.height - 32)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: currentStep == .before ? "fork.knife.circle" : "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange.opacity(0.6))
                        
                        Text(currentStep.instruction)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 로딩 오버레이
                if isCapturing {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .padding(16)
        }
    }
    
    private var currentImage: UIImage? {
        currentStep == .before ? beforeImage : afterImage
    }
    
    private var captureButton: some View {
        VStack(spacing: 16) {
            // 촬영 버튼
            Button {
                Task {
                    await capturePhoto()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.orange, lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
            }
            .disabled(isCapturing)
            
            // 다음 단계로 진행 버튼 (촬영 완료 시)
            if currentImage != nil {
                Button {
                    proceedToNextStep()
                } label: {
                    Text(currentStep == .before ? "다음" : "기록하기")
                        .font(.headline)
                        .frame(width: 200)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func capturePhoto() async {
        isCapturing = true
        
        let image = await captureService.capturePhoto(type: currentStep)
        
        await MainActor.run {
            isCapturing = false
            
            withAnimation(.easeInOut(duration: 0.3)) {
                if currentStep == .before {
                    beforeImage = image
                } else {
                    afterImage = image
                }
            }
        }
    }
    
    private func proceedToNextStep() {
        if currentStep == .before {
            withAnimation {
                currentStep = .after
            }
        } else {
            // 기록지로 이동
            showRecordForm = true
        }
    }
}

#Preview {
    NavigationStack {
        CaptureView()
    }
}
