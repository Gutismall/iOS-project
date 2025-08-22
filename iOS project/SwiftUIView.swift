import SwiftUI

class ProgressModel: ObservableObject {
    @Published var totalExpences: Double = UserViewModel.shared.totalUserExpences()
    @Published var monthlyBudget: Int = UserViewModel.shared.user.monthlyBudget
    
    func updateBudget() {
        monthlyBudget = UserViewModel.shared.user.monthlyBudget
        totalExpences = UserViewModel.shared.totalUserExpences()
    }
}

struct ProgressCircle: View {
    var progress: Double // 0.0 to 1.0 (clamped)
    var overBudget: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-225))
                .frame(width: 230, height: 230)
            Circle()
                .trim(from: 0, to: 0.75 * progress)
                .stroke(overBudget ? Color.red : Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-225))
                .frame(width: 230, height: 230)
            // Handle circle at the end of the progress arc
            GeometryReader { geo in
                let size = geo.size
                let radius = 115.0 // 230 / 2
                let angle = -225.0 + 270.0 * progress
                let rad = angle * .pi / 180
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let handleX = center.x + radius * cos(rad)
                let handleY = center.y + radius * sin(rad)
                Circle()
                    .fill(overBudget ? Color.red : Color.blue)
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    .position(x: handleX, y: handleY)
            }
            .frame(width: 230, height: 230)
        }
        .background(Color.clear)
    }
}

struct SwiftUIView: View {
    @ObservedObject var model: ProgressModel
    @State private var animatedProgress: Double = 0
    
    private var ratio: Double {
        guard model.monthlyBudget > 0 else { return 0 }
        return model.totalExpences / Double(model.monthlyBudget)
    }
    private var clampedRatio: Double { min(max(ratio, 0), 1) }
    private var overBudget: Bool { ratio > 1 }
    
    var body: some View {
        VStack {
            ZStack {
                ProgressCircle(progress: animatedProgress, overBudget: overBudget)
                Text(String(format: "%d/%d", Int(model.totalExpences), model.monthlyBudget))
                    .font(.system(size: 40))
                    .bold()
            }
            .background(Color.clear)
        }
        .background(Color.clear)
        .padding()
        .onAppear {
            animatedProgress = 0
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = clampedRatio
            }
        }
        .onChange(of: ratio) {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = clampedRatio
            }
        }
    }
}
