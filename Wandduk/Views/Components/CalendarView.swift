import SwiftUI

/// 커스텀 월간 캘린더 뷰
struct CalendarView: View {
    /// 기록이 있는 날짜별 기록 수 딕셔너리
    let recordCounts: [DateComponents: Int]
    
    /// 선택된 날짜
    @Binding var selectedDate: Date
    
    /// 현재 표시 중인 월
    @State private var displayedMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 월 네비게이션 헤더
            monthHeader
            
            // 요일 헤더
            weekdayHeader
            
            // 날짜 그리드
            dateGrid
        }
        .padding(.horizontal)
    }
    
    // MARK: - Month Header
    
    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.headline)
            
            // 오늘로 이동 버튼 (현재 월이 아닐 때만)
            if !isCurrentMonth {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = Date()
                        selectedDate = Date()
                    }
                } label: {
                    Text("오늘")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Weekday Header
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(symbol == "일" ? .red.opacity(0.7) : (symbol == "토" ? .blue.opacity(0.7) : .secondary))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Date Grid
    
    private var dateGrid: some View {
        let days = daysInMonth()
        let rows = days.count / 7
        
        return VStack(spacing: 2) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        let index = row * 7 + col
                        if index < days.count {
                            dateCell(for: days[index])
                        }
                    }
                }
            }
        }
    }
    
    private func dateCell(for day: CalendarDay) -> some View {
        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(day.date)
        let count = recordCount(for: day.date)
        
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedDate = day.date
            }
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    // 선택 배경
                    if isSelected {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 32, height: 32)
                    } else if isToday {
                        Circle()
                            .stroke(Color.orange.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                    }
                    
                    Text("\(calendar.component(.day, from: day.date))")
                        .font(.subheadline)
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundStyle(
                            isSelected ? .white :
                            !day.isCurrentMonth ? Color.gray.opacity(0.3) :
                            .primary
                        )
                }
                .frame(height: 32)
                
                // 기록 도트
                HStack(spacing: 2) {
                    if count > 0 && day.isCurrentMonth {
                        ForEach(0..<min(count, 3), id: \.self) { _ in
                            Circle()
                                .fill(isSelected ? Color.orange : Color.orange.opacity(0.6))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                .frame(height: 6)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .opacity(day.isCurrentMonth ? 1.0 : 0.3)
    }
    
    // MARK: - Helpers
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: displayedMonth)
    }
    
    private var isCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }
    
    private func moveMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let newDate = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
                displayedMonth = newDate
            }
        }
    }
    
    private func recordCount(for date: Date) -> Int {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return recordCounts[components] ?? 0
    }
    
    /// 현재 월에 표시할 날짜 배열 생성 (이전 월 꼬리 + 현재 월 + 다음 월 머리)
    private func daysInMonth() -> [CalendarDay] {
        var days: [CalendarDay] = []
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return days
        }
        
        // 6주(42일) 채우기
        var current = firstWeek.start
        for _ in 0..<42 {
            let isCurrentMonth = calendar.isDate(current, equalTo: displayedMonth, toGranularity: .month)
            days.append(CalendarDay(date: current, isCurrentMonth: isCurrentMonth))
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        
        return days
    }
}

/// 캘린더에 표시할 날짜 정보
private struct CalendarDay {
    let date: Date
    let isCurrentMonth: Bool
}

#Preview {
    CalendarView(
        recordCounts: [:],
        selectedDate: .constant(Date())
    )
}
