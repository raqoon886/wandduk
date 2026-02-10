import UIKit
import SwiftUI

/// 실제 카메라를 사용한 촬영 서비스
/// UIImagePickerController를 래핑하여 PhotoCaptureProtocol을 구현합니다.
final class CameraPhotoCaptureService: PhotoCaptureProtocol {
    
    func capturePhoto(type: CaptureType) async -> UIImage? {
        // UIImagePickerController 방식 대신,
        // CaptureView에서 직접 시트를 띄우는 방식으로 전환하므로
        // 이 메서드는 사용되지 않음. 호환성을 위해 nil 반환.
        return nil
    }
}

/// UIImagePickerController를 SwiftUI에서 사용할 수 있게 래핑
struct CameraPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // 카메라 사용 가능 여부 확인
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            // 시뮬레이터: 포토 라이브러리 폴백
            picker.sourceType = .photoLibrary
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
