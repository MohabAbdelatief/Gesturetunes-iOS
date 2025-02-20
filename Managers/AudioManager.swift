import AVFoundation

class AudioManager {
    // SHARED DELEGATE
    static let shared = AudioManager()
    
    // AUDIO PLAYER CONTROLLER OBJECT
    private var audioPlayer: AVAudioPlayer?
    
    // PROPERTIES
    private var timer: Timer?
    private var currentFileName: String?
    
    // MARK: - Published Properties
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    // MARK: - MUSIC PLAYBACK FUNCTIONS
    func play(songFileName: String) {
        // RESUME IF SAME FILE
        if let player = audioPlayer,
           !player.isPlaying,
           currentFileName == songFileName {
            player.play()
            startUpdatingCurrentTime()
            return
        }
        
        // RELOAD IF DIFFRENT FILE
        guard let url = Bundle.main.url(forResource: songFileName, withExtension: "mp3") else {
            print("Song file not found")
            return
        }
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            currentFileName = songFileName
            duration = audioPlayer?.duration ?? 0.0
            audioPlayer?.play()
            startUpdatingCurrentTime()
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    // PAUSE
    
    func pause() {
        audioPlayer?.pause()
    }
    
    // STOP
    
    func stop() {
        audioPlayer?.stop()
    }
    
    // VOLUME CHANGER
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
    
    // TOGGLE PLAYING
    
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    //  SEEK
    
    func seek(to time: Double) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        currentTime = time
    }
    
    //  UPDATE TIME
    
    private func startUpdatingCurrentTime() {
        stopUpdatingCurrentTime()  // Make sure we don't start multiple timers
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {
            [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopUpdatingCurrentTime() {
        timer?.invalidate()
        timer = nil
    }
}
