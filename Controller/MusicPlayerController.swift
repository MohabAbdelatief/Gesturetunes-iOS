import AVFoundation
import Combine
import MediaPlayer
import SwiftUI

class MusicPlayerController: ObservableObject {

    // MARK: - PUBLISHED PROPERTIES
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 1.0
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    // PLAYBACK LOCK SCREEN INTERFACE
    @Published var showNowPlaying: Bool = false

    // MARK: - PROPERTIES
    private var songs: [Song]
    private var cancellables = Set<AnyCancellable>()
    var currentSongIndex: Int = 0

    init(songs: [Song]) {
        self.songs = songs
        if !songs.isEmpty {
            currentSong = songs[0]
        }

        AudioManager.shared.$currentTime
            .receive(on: RunLoop.main)
            .assign(to: \.currentTime, on: self)
            .store(in: &cancellables)

        AudioManager.shared.$duration
            .receive(on: RunLoop.main)
            .assign(to: \.duration, on: self)
            .store(in: &cancellables)

        // PREPARE PLAYING INTERFACE FOR LOCK SCREEN.
        configureAudioSession()
        setupRemoteCommandCenter()
    }

    // MARK: - MUSIC PLAYBACK
    func play() {
        guard let song = currentSong else { return }

        AudioManager.shared.play(songFileName: song.fileName)
        isPlaying = true

        // Update Now Playing info (title, artist, rate, etc.)
        updateNowPlayingInfo()
    }

    func pause() {
        AudioManager.shared.pause()
        isPlaying = false

        updateNowPlayingInfo()
    }

    func next() {
        guard !songs.isEmpty else { return }
        currentSongIndex = (currentSongIndex + 1) % songs.count
        currentSong = songs[currentSongIndex]
        AudioManager.shared.seek(to: 0)

        play()
    }

    func previous() {
        guard !songs.isEmpty else { return }
        currentSongIndex = (currentSongIndex - 1 + songs.count) % songs.count
        currentSong = songs[currentSongIndex]
        AudioManager.shared.seek(to: 0)

        play()
    }

    func setVolume(_ volume: Float) {
        self.volume = volume
        AudioManager.shared.setVolume(volume)
    }

    func seek(to time: Double) {
        AudioManager.shared.seek(to: time)
        updateLockScreenElapsedTime(time)
    }

    // MARK: - PLAYBACK LOCK SCREEN INTERFACE
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        //  PLAY
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            self?.updateLockScreenPlaybackRate(isPlaying: true)
            return .success
        }

        //  PAUSE
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            self?.updateLockScreenPlaybackRate(isPlaying: false)
            return .success
        }

        //   NEXT
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.next()
            return .success
        }

        //   PREVIOUS
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previous()
            return .success
        }

        //   SEEK
        commandCenter.changePlaybackPositionCommand.addTarget {
            [weak self] event in
            guard let self = self,
                let positionEvent = event
                    as? MPChangePlaybackPositionCommandEvent
            else {
                return .commandFailed
            }

            self.seek(to: positionEvent.positionTime)
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let song = currentSong else { return }

        let title = song.title
        let artist = song.artist
        let elapsed = currentTime
        let trackDuration = duration

        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPMediaItemPropertyPlaybackDuration: trackDuration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]

        let artworkName = song.artwork
        if let artworkImage = UIImage(named: artworkName) {
            let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) {
                _ in
                return artworkImage
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func updateLockScreenPlaybackRate(isPlaying: Bool) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return
        }
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func updateLockScreenElapsedTime(_ time: Double) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return
        }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

}
