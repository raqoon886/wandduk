import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \MealRecord.createdAt, order: .reverse)
    private var records: [MealRecord]
    
    @State private var showCapture = false
    
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
                    archiveGridView
                }
                
                // FAB — 새 기록 시작
                fabButton
            }
            .navigationTitle("완뚝")
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
            .padding(.bottom, 100) // FAB과 겹치지 않도록
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
}

#Preview {
    ContentView()
        .modelContainer(for: MealRecord.self, inMemory: true)
}
