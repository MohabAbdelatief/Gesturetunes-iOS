import SwiftUI

struct CarModeTransitionView: View {
    @State private var carIconVisible = false
    @State private var textVisible = false
    @State private var navigateToCameraView = false

    var body: some View {
        ZStack {
            

            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.gray],
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .scaleEffect(carIconVisible ? 1.0 : 0.5)
                        .opacity(carIconVisible ? 1.0 : 0)
                        .animation(
                            .easeInOut(duration: 0.5), value: carIconVisible
                        )

                    // Text: "Car Mode Active"
                    Text("Activating Car Mode")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.gray],
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .scaleEffect(textVisible ? 1.0 : 0.5)
                        .opacity(textVisible ? 1.0 : 0) 
                        .animation(
                            .easeInOut(duration: 0.5).delay(0.2),
                            value: textVisible)
                }
            }
            .onAppear {
                // Trigger the animations
                DispatchQueue.main.async {
                    carIconVisible = true
                    textVisible = true
                }

                // Navigate to CameraView after animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    navigateToCameraView = true
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToCameraView) {
            CameraView()
        }
    }
}

#Preview {
    CarModeTransitionView()
}
