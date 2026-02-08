import SwiftUI

/// 7단계 스냅 슬라이더 (햅틱 피드백 포함)
struct TasteSlider: View {
    let dimension: TasteDimension
    @Binding var value: Int
    
    @State private var dragValue: Double = 4
    
    // 햅틱 피드백 제너레이터
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        VStack(spacing: 12) {
            // 상단: 아이콘 + 항목명 + 현재 평가
            HStack {
                Text(dimension.icon)
                    .font(.title2)
                Text(dimension.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // 동적 피드백 멘트
                Text(dimension.feedback(for: value))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(feedbackColor)
                    .animation(.easeInOut(duration: 0.15), value: value)
            }
            
            // 슬라이더 영역
            VStack(spacing: 4) {
                // 커스텀 슬라이더
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 트랙 배경
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 8)
                        
                        // 채워진 영역
                        Capsule()
                            .fill(sliderGradient)
                            .frame(width: thumbPosition(in: geometry.size.width), height: 8)
                        
                        // 눈금 표시
                        HStack(spacing: 0) {
                            ForEach(1...7, id: \.self) { step in
                                Circle()
                                    .fill(step <= value ? Color.white.opacity(0.8) : Color.gray.opacity(0.3))
                                    .frame(width: 6, height: 6)
                                if step < 7 {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        // 썸(Thumb)
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                            .overlay {
                                Circle()
                                    .stroke(thumbBorderColor, lineWidth: 2)
                            }
                            .offset(x: thumbPosition(in: geometry.size.width) - 14)
                    }
                    .frame(height: 28)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                updateValue(from: gesture.location.x, in: geometry.size.width)
                            }
                            .onEnded { _ in
                                impactFeedback.impactOccurred(intensity: 0.6)
                            }
                    )
                }
                .frame(height: 28)
                
                // 양 끝 라벨
                HStack {
                    Text(dimension.leftLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(dimension.rightLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            dragValue = Double(value)
            impactFeedback.prepare()
            selectionFeedback.prepare()
        }
    }
    
    // MARK: - Computed Properties
    
    private var feedbackColor: Color {
        switch value {
        case 1...2: return .blue
        case 3: return .teal
        case 4: return .green
        case 5: return .orange
        case 6...7: return .red
        default: return .primary
        }
    }
    
    private var sliderGradient: LinearGradient {
        LinearGradient(
            colors: [.orange.opacity(0.6), .orange],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var thumbBorderColor: Color {
        .orange.opacity(0.8)
    }
    
    // MARK: - Helper Functions
    
    private func thumbPosition(in width: CGFloat) -> CGFloat {
        let padding: CGFloat = 14 // 썸 반지름
        let trackWidth = width - (padding * 2)
        let stepWidth = trackWidth / 6.0
        let position = padding + (CGFloat(value - 1) * stepWidth)
        return min(max(position, padding), width - padding)
    }
    
    private func updateValue(from x: CGFloat, in width: CGFloat) {
        let padding: CGFloat = 14
        let trackWidth = width - (padding * 2)
        let clampedX = min(max(x - padding, 0), trackWidth)
        let stepWidth = trackWidth / 6.0
        let newValue = Int(round(clampedX / stepWidth)) + 1
        let clampedValue = min(max(newValue, 1), 7)
        
        if clampedValue != value {
            selectionFeedback.selectionChanged()
            withAnimation(.easeOut(duration: 0.1)) {
                value = clampedValue
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        TasteSlider(
            dimension: TasteDimension.gukbapDimensions[0],
            value: .constant(4)
        )
        TasteSlider(
            dimension: TasteDimension.gukbapDimensions[1],
            value: .constant(6)
        )
    }
    .padding()
}
