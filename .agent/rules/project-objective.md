---
trigger: always_on
---

# Project: 완뚝 (wandduk) - The Perfect Bowl Archive

## 1. Project Overview
"완뚝"은 국밥, 라멘과 같은 '한 그릇 음식'에 특화된 **버티컬 미식 기록 서비스**입니다. 단순히 무엇을 먹었는지 기록하는 것을 넘어, AI를 통해 음식의 특성을 분류하고 유저의 미세한 입맛 취향을 데이터화하여 시각적 보상(3D 디오라마)과 정교한 인사이트를 제공합니다.

- 프로젝트 목표와 세부사항은 유연하게 변경 가능함.

### 1.1 Core Mission
- **진심어린 기록:** '완뚝(그릇을 비움)'의 성취감을 디지털 자산으로 치환.
- **데이터 기반 취향 발견:** 유저도 몰랐던 미식 무의식을 데이터 분석으로 도출.
- **시각적 자산화:** 기록을 3D 이소메트릭 디오라마 형태로 수집하여 기록의 재미 극대화.

---

## 2. Target & Market Strategy
- **Target:** 특정 음식(국밥, 라멘 등)에 진심인 미식가, 자신의 취향을 정교하게 아카이빙하고 싶은 유저.
- **Vertical Approach:** 범용 식단 앱과 달리 '맛의 디테일(염도, 면의 익힘, 육수 종류 등)'에 집중하는 고밀도 서비스.

---

## 3. Core User Journey
1. **Photo Capture:** 식사 전(Before)과 완뚝 후(After) 사진 촬영.
2. **AI Classification:** CNN 모델이 음식 카테고리(예: 돼지국밥, 돈코츠 라멘 등)를 자동 식별 - 매뉴얼대로도 추후 변경 가능(미정)
3. **Smart Tagging:** 식별된 카테고리에 최적화된 맛 기록지(슬라이더/탭 방식) 제공 (ex: 짜다/싱겁다, 기름지다/담백하다).
4. **Visual Reward:** 기록 완료 시 해당 음식을 모티브로 한 **3D 디오라마 오브젝트** 생성 및 배치.
5. **Data Insight:** 누적된 데이터를 분석하여 유저의 미식 성향 리포트 발행.

---

## 4. Technical Architecture (Proposed) - 제안됨(변경가능)
- **Frontend:** SwiftUI (iOS) - 3D 렌더링을 위해 SceneKit 또는 RealityKit 활용.
- **AI/ML:** - **Classification:** On-device CNN (CoreML)을 활용한 경량화된 음식 분류.
    - **Insight:** 유저 패턴 분석을 위한 정규화된 데이터 엔진.
- **Database:** Realm 또는 CoreData (Local-first, Privacy 중심).
- **Backend:** Firebase 또는 Supabase (유저간 랭킹 및 데이터 동기화용, 추후 확장).

---

## 5. Key Priorities (Focused on Value 2 & 3)

### Priority A: Data Insights & Analysis (High)
- **Contextual Analysis:** 날씨, 시간, 장소와 유저의 맛 평가 사이의 상관관계 분석.
- **Predictive Scoring:** 누적 데이터를 바탕으로 특정 메뉴에 대한 유저의 '예상 만족도(완뚝 확률)' 계산.
- **Consistency Tracking:** 유저의 입맛이 얼마나 일관적인지, 혹은 특정 상황에서 어떻게 변하는지 추적.

### Priority B: Emotional Visuals & 3D Diorama (Medium-High)
- **Data-driven Visuals:** 유저가 기록한 '맛'의 특성(매운 정도 등)이 3D 오브젝트의 색상이나 이펙트에 반영됨.
- **Growth System:** 기록이 쌓일수록 유저만의 '미식 거리(Street)'가 3D로 확장되는 시각적 성취감 제공.

---

## 6. Data Schema (Draft)
- `MealRecord`: id, timestamp, category_id, location, photo_before, photo_after, sentiment_score.
- `TasteDimension`: saltiness, richness, spiciness, texture_score, etc. (Category-specific).
- `UserInsight`: preferred_style, weather_correlation, mood_impact_factor.

---

## 7. Future Roadmap
1. **MVP:** 국밥/라멘 카테고리 특화 기록 및 3D 오브젝트 수집 기능.
2. **v1.5:** AI 기반 미식 취향 분석 리포트 및 예측 엔진 고도화.
3. **v2.0:** '완뚝' 밈 기반의 소셜 랭킹 및 카테고리 확장 (커피, 위스키 등).