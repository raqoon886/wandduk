import SwiftUI

// MARK: - Euljiro Artisan Colors

extension Color {
    /// 펄펄 끓는 용암의 오렌지 (Glow Effect용)
    static let lavaOrange = Color(red: 1.0, green: 0.3, blue: 0.0) // #FF4D00
    
    /// 깊은 숯불 같은 다크 그레이
    static let charcoalBlack = Color(red: 0.1, green: 0.1, blue: 0.08) // #1A1A14
    
    /// 한지 느낌의 따뜻한 베이지
    static let brothBeige = Color(red: 0.96, green: 0.94, blue: 0.90) // #F5F0E6
    
    /// 잘 익은 깍두기 국물 색
    static let kimchiRed = Color(red: 0.85, green: 0.15, blue: 0.1) // #D9261A
    
    /// 오래된 놋그릇의 황동색
    static let brassGold = Color(red: 0.8, green: 0.6, blue: 0.2) // #CC9933
}

// MARK: - Wabi-Sabi Shapes

/// 완벽하지 않은, 손으로 빚은 듯한 모양
struct HandmadeShape: Shape {
    var irregularities: Int = 1
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 약간 찌그러진 사각형 (Squircle + Noise) 구현은 복잡하므로
        // 여기서는 RoundedRectangle에 약간의 랜덤성을 부여하는 식으로 흉내
        // 실제로는 베지에 곡선으로 불규칙하게 그려야 함. MVP에서는 부드러운 라운드로 타협하되
        // 뷰Modifier에서 회전을 줌.
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 16, height: 16))
        return path
    }
}

// MARK: - Modifiers

struct WabiSabiModifier: ViewModifier {
    let rotation: Double
    
    init() {
        // -1도 ~ 1도 사이의 미세한 회전 (자연스러운 불안정함)
        self.rotation = Double.random(in: -1.5...1.5)
    }
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
    }
}

extension View {
    /// 을지로 장인의 손길 (미세한 회전)
    func wabiSabi() -> some View {
        modifier(WabiSabiModifier())
    }
    
    /// 묵직한 그림자
    func heavyShadow() -> some View {
        self.shadow(color: .charcoalBlack.opacity(0.15), radius: 8, x: 2, y: 4)
    }
    
    /// 한지 질감 배경 적용
    func hanjiBackground() -> some View {
        self.background(Color.brothBeige)
            // 텍스처 이미지가 없으므로 노이즈 오버레이는 생략하거나 그라디언트로 대체
            .background(
                LinearGradient(
                    colors: [.white.opacity(0.2), .black.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
