import UIKit

/// 이미지 파일 저장/로드/삭제 서비스
/// Documents/WanddukImages/ 디렉토리에 JPEG로 저장하고, 상대 경로를 반환합니다.
enum ImageStorageService {
    
    /// 저장 디렉토리 이름
    private static let directoryName = "WanddukImages"
    
    /// JPEG 압축 품질 (0.0 ~ 1.0)
    private static let compressionQuality: CGFloat = 0.8
    
    // MARK: - Public API
    
    /// UIImage를 파일 시스템에 저장하고, 상대 경로를 반환
    /// - Returns: "WanddukImages/{uuid}.jpg" 형태의 상대 경로
    static func saveImage(_ image: UIImage) throws -> String {
        let directory = try ensureDirectory()
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = directory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageStorageError.compressionFailed
        }
        
        try data.write(to: fileURL)
        
        // 상대 경로 반환 (DB에 저장할 값)
        return "\(directoryName)/\(fileName)"
    }
    
    /// 상대 경로로부터 UIImage 로드
    static func loadImage(at relativePath: String) -> UIImage? {
        guard let url = fullURL(for: relativePath) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    /// 상대 경로에 해당하는 이미지 파일 삭제
    static func deleteImage(at relativePath: String) {
        guard let url = fullURL(for: relativePath) else { return }
        try? FileManager.default.removeItem(at: url)
    }
    
    /// 상대 경로 → 절대 URL 변환
    static func fullURL(for relativePath: String) -> URL? {
        guard !relativePath.isEmpty else { return nil }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsURL?.appendingPathComponent(relativePath)
    }
    
    // MARK: - Private
    
    /// 저장 디렉토리가 존재하지 않으면 생성
    private static func ensureDirectory() throws -> URL {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ImageStorageError.documentsDirectoryNotFound
        }
        
        let directoryURL = documentsURL.appendingPathComponent(directoryName)
        
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        
        return directoryURL
    }
}

// MARK: - Errors

enum ImageStorageError: LocalizedError {
    case compressionFailed
    case documentsDirectoryNotFound
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "이미지 압축에 실패했습니다."
        case .documentsDirectoryNotFound:
            return "Documents 디렉토리를 찾을 수 없습니다."
        }
    }
}
