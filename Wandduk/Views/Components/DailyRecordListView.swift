import SwiftUI

/// 선택된 날짜의 기록 리스트
struct DailyRecordListView: View {
    let records: [MealRecord]
    let selectedDate: Date
    var onDelete: ((MealRecord) -> Void)? = nil
    var onEdit: ((MealRecord) -> Void)? = nil
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack(spacing: 6) {
                Text(dateString)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if !filteredRecords.isEmpty {
                    Text("\(filteredRecords.count)개")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            if filteredRecords.isEmpty {
                // 빈 상태
                VStack(spacing: 8) {
                    Text("🍽️")
                        .font(.title)
                    Text("이 날은 기록이 없어요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                // 기록 리스트
                VStack(spacing: 8) {
                    ForEach(filteredRecords) { record in
                        NavigationLink {
                            RecordDetailView(record: record)
                        } label: {
                            dailyRecordRow(record)
                                .contextMenu {
                                    Button {
                                        onEdit?(record)
                                    } label: {
                                        Label("제멋대로 수정하기 (수정)", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        onDelete?(record)
                                    } label: {
                                        Label("기록 태우기 (삭제)", systemImage: "flame")
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Row
    
    private func dailyRecordRow(_ record: MealRecord) -> some View {
        HStack(spacing: 12) {
            // 썸네일
            Group {
                if let image = ImageStorageService.loadImage(at: record.beforeImagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(record.categoryEmoji)
                        .font(.subheadline)
                    Text(record.category)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text(record.createdAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(Color.gray.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helpers
    
    private var filteredRecords: [MealRecord] {
        records.filter { calendar.isDate($0.createdAt, inSameDayAs: selectedDate) }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: selectedDate)
    }
}

#Preview {
    NavigationStack {
        DailyRecordListView(records: [], selectedDate: Date())
    }
}
