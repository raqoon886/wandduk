import SwiftUI
import SwiftData

enum ArchiveViewMode {
    case grid
    case calendar
}

struct ContentView: View {
    @Query(sort: \MealRecord.createdAt, order: .reverse)
    private var records: [MealRecord]
    
    @Environment(\.modelContext) private var modelContext
    @State private var showCapture = false
    @State private var showInsight = false
    @State private var viewMode: ArchiveViewMode = .grid
    @State private var selectedDate: Date = Date()
    @State private var editingRecord: MealRecord?
    @State private var showDeleteAlert = false
    @State private var selectedRecordToDelete: MealRecord?
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // 네비게이션 타이틀 커스텀을 위한 초기화
    init() {
        // 네비게이션 바 스타일 설정 (장인 정신 폰트)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.brothBeige)
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold), // Serif가 없으면 시스템 볼드로
            .foregroundColor: UIColor(Color.charcoalBlack)
        ]
        appearance.titleTextAttributes = titleAttrs
        appearance.largeTitleTextAttributes = titleAttrs
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // 한지 배경
                Color.brothBeige.ignoresSafeArea()
                
                if records.isEmpty {
                    emptyStateView
                } else {
                    Group {
                        switch viewMode {
                        case .grid:
                            archiveGridView
                        case .calendar:
                            calendarArchiveView
                        }
                    }
                }
                
                // FAB — 뚝배기 뚜껑 열기
                fabButton
            }
            .navigationTitle("완뚝 아카이브")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "circle.grid.2x2.fill") // DNA/Insight Icon placeholder
                        .foregroundStyle(Color.charcoalBlack)
                        .onTapGesture {
                            showInsight = true
                        }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("완뚝")
                        .font(.title)
                        .fontDesign(.serif)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.charcoalBlack)
                }
                
                // 뷰 모드 토글 + 카메라
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 20) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewMode = viewMode == .grid ? .calendar : .grid
                            }
                        } label: {
                            Image(systemName: viewMode == .grid ? "calendar" : "square.grid.2x2")
                                .foregroundStyle(Color.charcoalBlack)
                        }
                        
                        Button {
                            showCapture = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(Color.charcoalBlack)
                        }
                    }
                }
            }
            .sheet(isPresented: $showInsight) {
                InsightView()
            }
            .fullScreenCover(isPresented: $showCapture) {
                CaptureView(dismissToRoot: $showCapture)
            }
            .overlay(deleteAlert)
            .fullScreenCover(item: $editingRecord) { record in
                NavigationStack {
                    RecordFormView(editingRecord: record)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 80))
                .foregroundStyle(Color.charcoalBlack.opacity(0.3))
            
            Text("아직 비운 뚝배기가 없습니다.")
                .font(.title3)
                .fontDesign(.serif)
                .foregroundStyle(Color.charcoalBlack)
            
            Text("첫 번째 완뚝을 기록해 보세요.")
                .font(.body)
                .fontDesign(.serif)
                .foregroundStyle(Color.charcoalBlack.opacity(0.6))
            
            Button {
                showCapture = true
            } label: {
                Text("첫 기록 시작하기")
                    .font(.headline)
                    .fontDesign(.serif)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.charcoalBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 16)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var archiveGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(records) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordCardView(record: record)
                            .wabiSabi() // 카드마다 미세한 회전
                            .contextMenu {
                                Button {
                                    editingRecord = record
                                } label: {
                                    Label("제멋대로 수정하기 (수정)", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    selectedRecordToDelete = record
                                    showDeleteAlert = true
                                } label: {
                                    Label("기록 태우기 (삭제)", systemImage: "flame")
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    private var calendarArchiveView: some View {
        ScrollView {
            VStack(spacing: 16) {
                CalendarView(
                    recordCounts: recordCountsByDate,
                    selectedDate: $selectedDate
                )
                .padding(.top, 16)
                
                Divider()
                    .background(Color.charcoalBlack.opacity(0.2))
                    .padding(.horizontal)
                
                DailyRecordListView(
                    records: records,
                    selectedDate: selectedDate,
                    onDelete: { record in
                        selectedRecordToDelete = record
                        showDeleteAlert = true
                    },
                    onEdit: { record in
                        editingRecord = record
                    }
                )
                .padding(.bottom, 100)
            }
        }
        .background(Color.brothBeige)
    }
    
    private var fabButton: some View {
        Button {
            showCapture = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.charcoalBlack)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.3), radius: 6, y: 4)
                
                Image(systemName: "plus")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.lavaOrange)
            }
        }
        .padding(.trailing, 24)
        .padding(.bottom, 24)
    }
    
    // MARK: - Helpers
    private var recordCountsByDate: [DateComponents: Int] {
        var counts: [DateComponents: Int] = [:]
        for record in records {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: record.createdAt)
            counts[components, default: 0] += 1
        }
        return counts
    }
    
    // MARK: - Deletion Logic
    
    private func deleteRecord(_ record: MealRecord) {
        // 이미지 삭제 (ImageStorageService 활용)
        ImageStorageService.deleteImage(at: record.beforeImagePath)
        ImageStorageService.deleteImage(at: record.afterImagePath)
        
        // 데이터베이스에서 삭제
        modelContext.delete(record)
    }
    
    private var deleteAlert: some View {
        EmptyView()
            .alert("기록을 태우시겠습니까?", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) {}
                Button("태우기", role: .destructive) {
                    if let record = selectedRecordToDelete {
                        deleteRecord(record)
                    }
                }
            } message: {
                Text("삭제된 기록은 되돌릴 수 없습니다.")
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MealRecord.self, inMemory: true)
}
struct TasteDNAView: View {
    let profile: TasteProfile
    
    // Animation state
    @State private var waveOffset = 0.0
    
    var body: some View {
        ZStack {
            // 그릇 (Bowl)
            BowlShape()
                .fill(Color.charcoalBlack)
                .frame(width: 240, height: 160)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            
            // 국물 (Broth)
            BowlContentShape()
                .fill(brothGradient)
                .frame(width: 220, height: 140)
                .offset(y: -5)
                .mask {
                    // 국물 수위 애니메이션? 일단 꽉 채움
                    BowlContentShape()
                }
                .opacity(brothOpacity)
            
            // 건더기 (Ingredients)
            GeometryReader { geometry in
                ZStack {
                    // 소금 (Salt)
                    ForEach(0..<Int(profile.averageSaltiness * 5), id: \.self) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 4, height: 4)
                            .position(randomPosition(in: geometry.size))
                    }
                    
                    // 고기/건더기 (Portion)
                    ForEach(0..<Int(profile.averagePortion * 3), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.brown)
                            .frame(width: 12, height: 8)
                            .rotationEffect(.degrees(Double.random(in: 0...360)))
                            .position(randomPosition(in: geometry.size))
                    }
                }
            }
            .frame(width: 200, height: 100)
            .offset(y: -10)
        }
    }
    
    // MARK: - Computed Properties
    
    private var brothGradient: LinearGradient {
        // Spiciness: 1 (Clear/Yellow) -> 7 (Red/Dark Red)
        let intensity = max(0, min(1, (profile.averageSpiciness - 1) / 6.0))
        
        let startColor = Color.yellow.opacity(0.6)
        let endColor = Color.kimchiRed
        
        // simple interpolation logic
        let color = Color.mix(startColor, endColor, percentage: intensity)
        
        return LinearGradient(
            colors: [color.opacity(0.8), color],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var brothOpacity: Double {
        // Richness: 1 (0.6) -> 7 (1.0)
        let base = 0.6
        let added = max(0, min(0.4, (profile.averageRichness - 1) / 6.0 * 0.4))
        return base + added
    }
    
    private func randomPosition(in size: CGSize) -> CGPoint {
        // 타원형 분포를 위해 중심에서 랜덤 거리/각도
        let radiusX = size.width / 2 * 0.8
        let radiusY = size.height / 2 * 0.8
        
        let angle = Double.random(in: 0...2 * .pi)
        let r = Double.random(in: 0...1) // sqrt for uniform distribution in circle, but oval is okay linear
        
        let x = size.width / 2 + r * radiusX * cos(angle)
        let y = size.height / 2 + r * radiusY * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Shapes

struct BowlShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 뚝배기 모양 (아래가 둥근 사다리꼴)
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: 0, y: h * 0.2))
        path.addLine(to: CGPoint(x: w, y: h * 0.2))
        path.addCurve(to: CGPoint(x: w * 0.8, y: h), control1: CGPoint(x: w, y: h * 0.8), control2: CGPoint(x: w * 0.9, y: h))
        path.addLine(to: CGPoint(x: w * 0.2, y: h))
        path.addCurve(to: CGPoint(x: 0, y: h * 0.2), control1: CGPoint(x: w * 0.1, y: h), control2: CGPoint(x: 0, y: h * 0.8))
        
        path.closeSubpath()
        return path
    }
}

struct BowlContentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // 윗면 (국물 표면) - 약간의 곡선
        path.move(to: CGPoint(x: 0, y: h * 0.2))
        path.addQuadCurve(to: CGPoint(x: w, y: h * 0.2), control: CGPoint(x: w/2, y: h * 0.25))
        
        // 아래쪽은 BowlShape와 유사하게
        path.addCurve(to: CGPoint(x: w * 0.8, y: h), control1: CGPoint(x: w, y: h * 0.8), control2: CGPoint(x: w * 0.9, y: h))
        path.addLine(to: CGPoint(x: w * 0.2, y: h))
        path.addCurve(to: CGPoint(x: 0, y: h * 0.2), control1: CGPoint(x: w * 0.1, y: h), control2: CGPoint(x: 0, y: h * 0.8))
        path.closeSubpath()
        return path
    }
}

// Helper for Color mixing
extension Color {
    static func mix(_ color1: Color, _ color2: Color, percentage: Double) -> Color {
        // Very basic mixing - SwiftUI styling isn't easy to interpolate linearly without UIColor
        // For now, simpler logic:
        // percentage < 0.5 ? color1 : color2 for simple switch, or ideally UIColor interpolation.
        // Let's implement UIColor based mixing.
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let p = CGFloat(percentage)
        let r = r1 + (r2 - r1) * p
        let g = g1 + (g2 - g1) * p
        let b = b1 + (b2 - b1) * p
        let a = a1 + (a2 - a1) * p
        
        return Color(uiColor: UIColor(red: r, green: g, blue: b, alpha: a))
    }
}
struct InsightView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var records: [MealRecord]
    
    private var profile: TasteProfile {
        StatisticsService.calculateProfile(from: records)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 1. DNA Visualization
                    VStack(spacing: 16) {
                        Text("나의 국밥 DNA")
                            .font(.title2)
                            .fontDesign(.serif)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.charcoalBlack)
                        
                        ZStack {
                            Circle()
                                .fill(Color.brothBeige)
                                .frame(width: 280, height: 280)
                                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
                            
                            TasteDNAView(profile: profile)
                                .scaleEffect(1.2)
                                .offset(y: 10)
                        }
                        .frame(height: 300)
                    }
                    .padding(.top, 20)
                    
                    // 2. Interpretation
                    VStack(spacing: 12) {
                        Text(StatisticsService.generateDescription(for: profile))
                            .font(.title3)
                            .fontDesign(.serif)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.charcoalBlack)
                            .padding(.horizontal)
                        
                        Text("총 \(profile.totalRecords)그릇의 완뚝 기록을 분석했습니다.")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // 3. Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        StatCard(title: "평균 맵기", value: profile.averageSpiciness, icon: "flame.fill", color: .kimchiRed)
                        StatCard(title: "평균 농도", value: profile.averageRichness, icon: "drop.fill", color: .brown)
                        StatCard(title: "평균 염도", value: profile.averageSaltiness, icon: "circle.grid.cross.fill", color: .gray)
                        StatCard(title: "평균 양", value: profile.averagePortion, icon: "fork.knife", color: .charcoalBlack)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("미식 인사이트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundStyle(Color.charcoalBlack)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
                Text(String(format: "%.1f", value))
                    .font(.title2)
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.charcoalBlack)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.brothBeige.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
