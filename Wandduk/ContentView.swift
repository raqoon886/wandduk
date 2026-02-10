import SwiftUI
import SwiftData

/// 뷰 모드
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
    
    private let calendar = Calendar.current
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if records.isEmpty {
                    emptyStateView
                } else {
                    switch viewMode {
                    case .grid:
                        archiveGridView
                    case .calendar:
                        calendarArchiveView
                    }
                }
                
                // FAB — 새 기록 시작
                fabButton
            }
            .navigationTitle("완뚝")
            .toolbar {
                // 뷰 모드 토글 (기록이 있을 때만 표시)
                if !records.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewMode = viewMode == .grid ? .calendar : .grid
                            }
                        } label: {
                            Image(systemName: viewMode == .grid ? "calendar" : "square.grid.2x2")
                                .font(.body)
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
        VStack(spacing: 20) {
            Spacer()
            
            Text("🍜")
                .font(.system(size: 80))
            
            Text("아직 기록이 없어요")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("첫 번째 완뚝을 기록해보세요!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                showCapture = true
            } label: {
                Label("기록 시작하기", systemImage: "camera.fill")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(.orange.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var archiveGridView: some View {
        ScrollView {
            // 상단 요약
            HStack {
                Text("총 \(records.count)개의 기록")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(records) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordCardView(record: record)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
    
    private var calendarArchiveView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 캘린더
                CalendarView(
                    recordCounts: recordCountsByDate,
                    selectedDate: $selectedDate
                )
                
                Divider()
                    .padding(.horizontal)
                
                // 선택된 날짜의 기록 리스트
                DailyRecordListView(
                    records: records,
                    selectedDate: selectedDate
                )
                .padding(.bottom, 100)
            }
            .padding(.top, 8)
        }
    }
    
    private var fabButton: some View {
        Button {
            showCapture = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(.orange.gradient)
                .clipShape(Circle())
                .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - Helpers
    
    /// 날짜별 기록 수를 계산
    private var recordCountsByDate: [DateComponents: Int] {
        var counts: [DateComponents: Int] = [:]
        for record in records {
            let components = calendar.dateComponents([.year, .month, .day], from: record.createdAt)
            counts[components, default: 0] += 1
        }
        return counts
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MealRecord.self, inMemory: true)
}
