import UIKit

/// Mock 촬영 서비스 - 개발/시뮬레이터 환경용
/// 번들에 포함된 샘플 이미지를 반환함
final class MockPhotoCaptureService: PhotoCaptureProtocol {
    
    /// 샘플 이미지 목록 (Asset Catalog에 등록된 이름)
    private let sampleImageNames = ["SampleGukbap", "SampleRamen"]
    
    func capturePhoto(type: CaptureType) async -> UIImage? {
        // 실제 카메라처럼 약간의 딜레이 추가
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초
        
        // 랜덤하게 샘플 이미지 선택
        guard let imageName = sampleImageNames.randomElement() else {
            return nil
        }
        
        return UIImage(named: imageName)
    }
}
