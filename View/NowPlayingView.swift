import SwiftUI

struct NowPlayingView: View {

    // MARK: - SHARED MUSIC PLAYER

    @EnvironmentObject var musicPlayer: MusicPlayerController

    // MARK: - STATE PROPERTY

    @State private var isDragging: Bool = false

    // MARK: - STATE PROPERTY
    @State private var playbackPosition: Double = 0.0

    var body: some View {

        VStack {
            Spacer()

            // MARK: - Song Details

            VStack(spacing: 16) {
                if let currentSong = musicPlayer.currentSong {
                    Image(currentSong.artwork)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .cornerRadius(16)
                        .shadow(
                            color: .black.opacity(0.8), radius: 12, x: 0, y: 8)

                    VStack(spacing: 8) {
                        Text(currentSong.title)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)

                        Text(currentSong.artist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }

            Spacer()

            // MARK: - Progress Slider
            
            VStack(spacing: 8) {
                // Time Labels
                HStack {
                    // Current Time
                    Text(formatTime(musicPlayer.currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .shadow(
                            color: .black.opacity(0.8), radius: 12, x: 0, y: 8)

                    Spacer()

                    // Total Duration
                    Text(formatTime(musicPlayer.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .shadow(
                            color: .black.opacity(0.8), radius: 12, x: 0, y: 8)
                }
                .padding(.horizontal, 40)
                .shadow(
                    color: .black.opacity(0.8), radius: 12, x: 0, y: 8)

                // The Slider
                Slider(
                    value: Binding(
                        get: {
                            // Update playbackPosition if not currently dragging
                            isDragging
                                ? playbackPosition : musicPlayer.currentTime
                        },
                        set: { newValue in
                            playbackPosition = newValue
                        }
                    ),
                    in: 0...musicPlayer.duration,
                    onEditingChanged: { editing in
                        isDragging = editing
                        if !editing {
                            // When user stops dragging, we seek
                            musicPlayer.seek(to: playbackPosition)
                        }
                    }
                )
                .tint(.blue)
                .shadow(color: .blue.opacity(0.8), radius: 4, x: 0, y: 3)
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 20)

            // MARK: - Playback Controls

            VStack(spacing: 16) {
                HStack(spacing: 50) {
                    Button(action: {
                        musicPlayer.previous()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.primary)
                            .shadow(
                                color: Color.black.opacity(0.8), radius: 2,
                                x: 0, y: 1)
                    }

                    Button(action: {
                        if musicPlayer.isPlaying {
                            musicPlayer.pause()
                        } else {
                            musicPlayer.play()
                        }
                    }) {
                        Image(
                            systemName: musicPlayer.isPlaying
                                ? "pause.circle.fill" : "play.circle.fill"
                        )
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                        .shadow(
                            color: .blue.opacity(0.5), radius: 6, x: 0, y: 4)
                    }

                    Button(action: {
                        musicPlayer.next()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.primary)
                            .shadow(
                                color: Color.black.opacity(0.8), radius: 2,
                                x: 0, y: 1)
                    }
                }
            }

            Spacer()

            // MARK: - Volume Slider

            VStack(spacing: 12) {
                Text("Volume")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .shadow(
                        color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)

                HStack {
                    Image(systemName: "speaker.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .shadow(
                            color: Color.black.opacity(0.8), radius: 2, x: 0,
                            y: 1)

                    Slider(
                        value: Binding(
                            get: { musicPlayer.volume },
                            set: { newValue in
                                musicPlayer.setVolume(newValue)
                            }
                        ), in: 0.0...1.0
                    )
                    .tint(.blue)
                    .shadow(color: .blue.opacity(0.8), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 8)

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .shadow(
                            color: Color.black.opacity(0.8), radius: 2, x: 0,
                            y: 1)
                }
                .padding(.horizontal, 40)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.gray, Color.blue.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Now Playing")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Time Formatting Helper
    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN, !time.isInfinite else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NowPlayingView()
        .environmentObject(MusicPlayerController(songs: Song.mockPlaylist()))
}
