import SwiftUI
import SwiftData

struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let record: MealRecord
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false
    @State private var selectedZoomItem: ImageItem?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 영수증/메뉴판 컨셉의 카드
                VStack(spacing: 24) {
                    // 상단 사진
                    HStack(spacing: 12) {
                        polaroid(imagePath: record.beforeImagePath)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.charcoalBlack.opacity(0.5))
                        polaroid(imagePath: record.afterImagePath)
                    }
                    
                    Divider().background(Color.charcoalBlack.opacity(0.2))
                    
                    // 맛 평가 도트
                    tasteResultSection
                    
                    if let memo = record.memo {
                        Divider().background(Color.charcoalBlack.opacity(0.2))
                        Text(memo)
                            .font(.body)
                            .fontDesign(.serif)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    
                    // 날짜 스탬프
                    HStack {
                        Spacer()
                        Text(record.createdAt, format: .dateTime.year().month().day())
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color.charcoalBlack.opacity(0.6))
                    }
                }
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 2)) // 각진 영수증 느낌
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                .padding(20)
                
                // 삭제 버튼
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("기록 태우기 (삭제)")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                        .padding()
                }
            }
            .padding(.top, 20)
        }
        .background(Color.brothBeige.ignoresSafeArea())
        .navigationTitle(record.category)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("삭제", isPresented: $showDeleteConfirmation) {
            Button("삭제", role: .destructive) { deleteRecord() }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("수정") {
                    showEditSheet = true
                }
            }
        }
        .fullScreenCover(isPresented: $showEditSheet) {
            NavigationStack {
                RecordFormView(editingRecord: record)
            }
        }
        .fullScreenCover(item: $selectedZoomItem) { item in
            ZoomOverlayView(image: item.image) {
                // 애니메이션 없이 즉시 닫기 (내부적으로 페이드 아웃 후 호출됨)
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    selectedZoomItem = nil
                }
            }
            .presentationBackground(.clear) // 배경 투명 처리 (iOS 16.4+)
        }
    }
    
    private func polaroid(imagePath: String) -> some View {
        Group {
            if let image = ImageStorageService.loadImage(at: imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // 애니메이션 없이 시트 띄우기 (커스텀 페이드 인을 위해)
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            selectedZoomItem = ImageItem(image: image)
                        }
                    }
            } else {
                Rectangle().fill(Color.gray.opacity(0.2))
            }
        }
        .frame(width: 100, height: 100)
        .border(Color.charcoalBlack.opacity(0.1), width: 1)
    }
    
    private var tasteResultSection: some View {
        VStack(spacing: 12) {
            ForEach(TasteDimension.gukbapDimensions) { dim in
                let value = getValue(for: dim.id)
                HStack {
                    Text(dim.name).font(.caption).bold().foregroundStyle(Color.charcoalBlack)
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<7) { i in
                            Circle()
                                .fill(i < value ? Color.lavaOrange : Color.gray.opacity(0.1))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }
        }
    }
    
    private func getValue(for id: String) -> Int {
        switch id {
        case "saltiness": return record.saltiness
        case "richness": return record.richness
        case "spiciness": return record.spiciness
        case "portion": return record.portion
        case "sideDish": return record.sideDish
        default: return 0
        }
    }
    
    private func deleteRecord() {
        ImageStorageService.deleteImage(at: record.beforeImagePath)
        ImageStorageService.deleteImage(at: record.afterImagePath)
        modelContext.delete(record)
        dismiss()
    }
}

struct ImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ZoomOverlayView: View {
    let image: UIImage
    let onDismiss: () -> Void
    
    @State private var appear = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
                .opacity(appear ? 1.0 : 0.0)
            
            ZoomableImageView(image: image)
                .ignoresSafeArea()
                .opacity(appear ? 1.0 : 0.0)
                .onTapGesture {
                    close()
                }
            
            Button {
                close()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding()
                    .padding(.top, 40)
                    .opacity(appear ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                appear = true
            }
        }
    }
    
    private func close() {
        withAnimation(.easeIn(duration: 0.2)) {
            appear = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// MARK: - ZoomableImageView
struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .black
        
        // 이미지 뷰 생성
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        
        // Auto Layout: 스크롤 뷰와 동일한 크기 (초기 상태)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        // 더블 탭 제스처
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if let imageView = context.coordinator.imageView, imageView.image != image {
            imageView.image = image
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableImageView
        var imageView: UIImageView?
        
        init(_ parent: ZoomableImageView) {
            self.parent = parent
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else { return }
            
            if scrollView.zoomScale > 1.0 {
                scrollView.setZoomScale(1.0, animated: true)
            } else {
                let point = gesture.location(in: imageView)
                let scrollSize = scrollView.frame.size
                let size = CGSize(width: scrollSize.width / scrollView.maximumZoomScale,
                                  height: scrollSize.height / scrollView.maximumZoomScale)
                let origin = CGPoint(x: point.x - size.width / 2,
                                     y: point.y - size.height / 2)
                scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
            }
        }
    }
}
