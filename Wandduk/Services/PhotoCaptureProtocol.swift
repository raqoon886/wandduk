import UIKit

/// 촬영 타입: 식사 전(Before) / 완뚝 후(After)
enum CaptureType {
    case before
    case after
    
    var title: String {
        switch self {
        case .before: return "식사 전"
        case .after: return "완뚝!"
        }
    }
    
    var instruction: String {
        switch self {
        case .before: return "맛있는 음식을 촬영해주세요"
        case .after: return "깨끗하게 비운 그릇을 촬영해주세요"
        }
    }
}

/// 촬영 서비스 프로토콜
/// Mock과 실제 카메라 구현을 교체 가능하게 함
protocol PhotoCaptureProtocol {
    /// 사진 촬영 (비동기)
    func capturePhoto(type: CaptureType) async -> UIImage?
}
