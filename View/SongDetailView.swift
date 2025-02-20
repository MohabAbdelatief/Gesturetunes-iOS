import SwiftUI

struct SongDetailView: View {
    
    // MARK: - Properties
    
    let song: Song
    
    // MARK: - STATE TRACKER FOR ANIMATIONS
    
    @State private var slideUp: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // MARK: - SONG DETAILS
            
            VStack {
                Image(song.artwork)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(20)
                
                Text(song.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(song.artist)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .offset(y: slideUp ? 0 : UIScreen.main.bounds.height) // Start below the screen
            .animation(.easeOut(duration: 0.5), value: slideUp) // Smooth slide animation
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.white, Color.blue.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
        .onAppear {
            slideUp = true
        }
    }
}

#Preview {
    let sampleSong = Song(
        title: "Pretty Little Devil",
        artist: "Shaya Zamora",
        artwork: "PrettyLittleDevil",
        fileName: "Pretty Little Devil"
    )
    SongDetailView(song: sampleSong)
}
