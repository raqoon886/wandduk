import SwiftUI
import SwiftData

enum ArchiveViewMode {
    case grid
    case calendar
}

struct ContentView: View {
    @Query(sort: \MealRecord.createdAt, order: .reverse)
    private var records: [MealRecord]
    
    @State private var showCapture = false
    @State private var viewMode: ArchiveViewMode = .grid
    @State private var selectedDate: Date = Date()
    
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
                // 뷰 모드 토글
                if !records.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewMode = viewMode == .grid ? .calendar : .grid
                            }
                        } label: {
                            Image(systemName: viewMode == .grid ? "calendar" : "square.grid.2x2")
                                .foregroundStyle(Color.charcoalBlack)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showCapture) {
                CaptureView(dismissToRoot: $showCapture)
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
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .padding(.bottom, 100)
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
                    selectedDate: selectedDate
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
}

#Preview {
    ContentView()
        .modelContainer(for: MealRecord.self, inMemory: true)
}
