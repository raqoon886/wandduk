import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Logo / Title
                VStack(spacing: 8) {
                    Text("🍜")
                        .font(.system(size: 80))
                    Text("완뚝")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("The Perfect Bowl Archive")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Main Action Button
                NavigationLink {
                    CaptureView()
                } label: {
                    Label("기록 시작하기", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                
                Spacer()
                    .frame(height: 60)
            }
            .navigationTitle("")
        }
    }
}

#Preview {
    ContentView()
}
