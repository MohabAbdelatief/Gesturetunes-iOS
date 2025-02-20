import AVFoundation
import SwiftUI

struct CameraView: View {

    // MARK: - PROPERTIES

    @State private var carIconVisible = false
    @State private var textVisible = false
    @State private var showLibrary = false
    @StateObject private var cameraModel = CameraModel()

    @EnvironmentObject var musicPlayer: MusicPlayerController

    var body: some View {

        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // MARK: - CAMERA
//                                        Rectangle()
//                                            .fill(Color.gray)
//                                            .frame(width: 350, height: 600)
//                                            .cornerRadius(15)
//                                            .overlay(Text("Camera Placeholder").foregroundColor(.white))
//                                            .padding(.top, 10)
                    CameraPreview(session: cameraModel.captureSession)
                        .frame(width: 350, height: 600)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding()
                    //  MARK: - DETECTED GESTURE
                    Text("Detected Gesture: \(cameraModel.detectedGesture)")
                        .frame(width: 325)
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.gray],
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                }
                .padding(.bottom, 50)

                // MARK: - MINI PLAYER
                if musicPlayer.currentSong != nil {
                    VStack {
                        Spacer()
                        MiniPlayerUI(selectedSong: .constant(nil))
                            .padding(.bottom, 8)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: - PLAYLIST
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showLibrary = true
                    }) {
                        Image(systemName: "music.note.list")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.gray],
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            .padding(.top, 10)
                            .padding(.leading, 15)
                    }
                }
            }

            // MARK: - LOGO

            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.gray],
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            .padding(.top, 10)
                            .scaleEffect(carIconVisible ? 1.0 : 0.5)
                            .opacity(carIconVisible ? 1.0 : 0)
                            .animation(
                                .easeInOut(duration: 0.5), value: carIconVisible
                            )

                        Text("Car Mode Active")
                            .font(.system(size: 20, weight: .bold))
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
                                value: textVisible
                            )
                            .padding(.top, 10)
                    }
                    .onAppear {
                        // Trigger the animations
                        DispatchQueue.main.async {
                            carIconVisible = true
                            textVisible = true
                        }
                    }
                }
            }
        }
        .onAppear {
            cameraModel.musicPlayer = musicPlayer
            cameraModel.startSession()
        }
        .onDisappear {
            cameraModel.stopSession()
        }
        .fullScreenCover(isPresented: $showLibrary) {
            Library()
            //                .environmentObject(musicPlayer)
        }
    }

}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

}

//#Preview {
//    CameraView()
//        .environmentObject(MusicPlayerController(songs: Song.mockPlaylist()))
//}

