import SwiftUI

struct Library: View {

    // MARK: - STATE PROPERTIES
    
    @State private var detectedGesture: String = "No Gesture"
    @State private var selectedSong: Song? = nil
    @State private var nowPlayingSong: Song? = nil
    @State private var detailedSong: Song? = nil
    @State private var isPlaying: Bool = false
    @State private var showCameraView: Bool = false
    @State private var searchText: String = ""
    @State private var showCarModeTransition = false
    @State private var showFileImporter: Bool = false
    
    // MARK: - ENVIROMENT OBJECTS

    @EnvironmentObject var musicPlayer: MusicPlayerController

    // MARK: - PROPERTIES

    private let playlist = Song.mockPlaylist()

    // MARK: - Computed Properties

    private func selectedIndex(for song: Song) -> Int {
        playlist.firstIndex(of: song) ?? 0
    }

    // MARK: - FUNCTIONS

    private func playNextSong() {
        guard let currentSong = nowPlayingSong,
            let currentIndex = playlist.firstIndex(of: currentSong)
        else { return }
        let nextIndex = (currentIndex + 1) % playlist.count
        nowPlayingSong = playlist[nextIndex]
        isPlaying = true
    }

    // MARK: - FILTERED PLAYLIST

    private var filteredPlaylist: [Song] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return playlist
        } else {
            return playlist.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText)
                    || song.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // MARK: - MUSIC LIST

    var body: some View {
        NavigationView {
            ZStack {
                // Search Bar
                VStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search Songs or Artists", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 8)
                            .foregroundColor(.primary)
                            .keyboardType(.default)
                    }
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 16)  // Adjust horizontal padding as needed
                    .padding(.top, 8)  // Reduced top padding
                    // Main List
                    List(filteredPlaylist.indices, id: \.self) { index in
                        SongView(
                            song: filteredPlaylist[index],
                            isPlaying: musicPlayer.currentSong
                                == filteredPlaylist[index]
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            musicPlayer.currentSong = filteredPlaylist[index]
                            musicPlayer.currentSongIndex = index
                            musicPlayer.play()
                        }
                        .simultaneousGesture(
                            LongPressGesture()
                                .onEnded { _ in
                                    detailedSong = filteredPlaylist[index]
                                }
                        )
                        .listRowSeparator(.hidden)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
                .listStyle(PlainListStyle())
                .padding(.bottom, 100)
                .listStyle(PlainListStyle())
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        // Modern Library Headline
                        Text("Library")
                            .font(.system(size: 45, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.gray],
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            .padding(.top, 40)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showCarModeTransition = true
                        }) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 20))

                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.blue, Color.gray],
                                        startPoint: .leading,
                                        endPoint: .trailing)
                                )
                                .padding(10)
                                .shadow(
                                    color: .black.opacity(0.2), radius: 5, x: 0,
                                    y: 4)
                        }
                        .padding(.trailing, 8)
                        .padding(.top, 40)

                    }
                }
                // Mini-Player
                if musicPlayer.currentSong != nil {
                    VStack {
                        Spacer()

                        ZStack {
                            // Blurred Background
                            VisualEffectBlur(blurStyle: .systemMaterial)
                                .edgesIgnoringSafeArea(.bottom)

                            // Mini Player Content
                            MiniPlayerUI(selectedSong: $selectedSong)

                                .padding(.bottom, 8)
                                .padding(.top, 15)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)  // Adjust this height as needed
                    }
                }
            }
            .sheet(isPresented: $showCameraView) {
                CameraView()
                    .environmentObject(musicPlayer)
            }
            .sheet(item: $selectedSong) { song in
                NowPlayingView()
                    .environmentObject(musicPlayer)
            }
            .sheet(item: $detailedSong) { song in
                SongDetailView(song: song)
            }
            .fullScreenCover(isPresented: $showCarModeTransition) {
                CarModeTransitionView()
                    .environmentObject(musicPlayer)
            }
        }
    }
}

// MARK: - MINI PLAYER UI

struct MiniPlayerUI: View {
    @EnvironmentObject var musicPlayer: MusicPlayerController
    @Binding var selectedSong: Song?

    var body: some View {
        HStack(spacing: 16) {

            // MARK: - SONG DETAILS

            if let currentSong = musicPlayer.currentSong {
                Image(currentSong.artwork)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading) {
                if let currentSong = musicPlayer.currentSong {
                    Text(currentSong.title)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Text(currentSong.artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // MARK: - PLAYBACK CONTROLS

            HStack(spacing: 20) {
                Button(action: {
                    musicPlayer.previous()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                        .shadow(
                            color: .black.opacity(0.4), radius: 12, x: 0, y: 8)
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
                            ? "pause.fill" : "play.fill"
                    )
                    .font(.title)
                    .foregroundColor(.primary)
                    .shadow(
                        color: .black.opacity(0.4), radius: 12, x: 0, y: 8)
                }
                .contentShape(Rectangle())

                Button(action: {
                    musicPlayer.next()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                        .shadow(
                            color: .black.opacity(0.4), radius: 12, x: 0, y: 8)
                }
                .contentShape(Rectangle())

            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            VisualEffectBlur(blurStyle: .systemMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .onTapGesture {
            if musicPlayer.currentSong != nil {
                selectedSong = musicPlayer.currentSong
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Blurry Background Modifier

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

// MARK: - Song Row Subview

struct SongView: View {
    let song: Song
    var isPlaying: Bool
    @State private var duration: String = "--:--"  // Placeholder for duration

    var body: some View {
        HStack {
            Image(song.artwork)
                .resizable()
                .frame(width: 64, height: 64)
                .cornerRadius(10)

            // Song Details
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .fontWeight(isPlaying ? .bold : .regular)
                    .foregroundColor(isPlaying ? .blue : .primary)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(duration)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .onAppear {
                    // Fetch the duration when the view appears
                    Task {
                        if let timeInterval = try? await song.getDuration() {
                            duration = formatTimeInterval(timeInterval)
                        }
                    }
                }
                .padding(.trailing, 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
        )
    }

    // Helper function to format time interval into MM:SS
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%2d:%02d", minutes, seconds)
    }
}

#Preview {
    Library()
        .environmentObject(MusicPlayerController(songs: Song.mockPlaylist()))
}
