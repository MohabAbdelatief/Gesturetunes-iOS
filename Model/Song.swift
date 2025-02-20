import AVFoundation
import CoreML
import Foundation
import Vision
import VisionKit

// MARK: - SONG STRUCTURE

struct Song: Identifiable, Equatable {
    let id: UUID = UUID()
    let title: String
    let artist: String
    let artwork: String
    let fileName: String
    // Method to get the duration of the song
    func getDuration() async throws -> TimeInterval? {
        guard
            let url = Bundle.main.url(
                forResource: fileName, withExtension: "mp3")
        else {
            print("Song file not found: \(fileName)")
            return nil
        }
        let asset = AVURLAsset(url: url)
        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            print("Error loading duration: \(error)")
            throw error
        }
    }

}

// MARK: - SAMPLE DATA FOR TEMPORARY USE

extension Song {
    static func mockPlaylist() -> [Song] {
        return [
            Song(
                title: "LUNCH", artist: "Billie Eilish", artwork: "Lunch",
                fileName: "LUNCH"),
            Song(
                title: "Pretty Little Devil", artist: "Shaya Zamora",
                artwork: "PrettyLittleDevil",
                fileName: "Pretty Little Devil"),
            Song(
                title: "Happy Nation", artist: "Ace Of Base",
                artwork: "HappyNation", fileName: "Happy Nation"
            ),
            Song(
                title: "Happy", artist: "NF", artwork: "Happy",
                fileName: "Happy"),
            Song(
                title: "Dirty", artist: "KSI",
                artwork: "Dirty",
                fileName: "Dirty"),
            Song(
                title: "I'd Rather Pretend", artist: "Bryant Barnes ft.d4vd",
                artwork: "I'dRatherPretend", fileName: "I'dRatherPretend"
            ),
            Song(
                title: "Clouds", artist: "NF", artwork: "Clouds",
                fileName: "CLOUDS"),
            Song(
                title: "The Search", artist: "NF",
                artwork: "TheSearch",
                fileName: "TheSearch"),
            Song(
                title: "In The Flood", artist: "Ariana Gillis",
                artwork: "InTheFlood", fileName: "InTheFlood"),
        ]
    }
}
