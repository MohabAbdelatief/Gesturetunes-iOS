//
//  LaunchView.swift
//  Gesturetunes
//
//  Created by Mohab Abdelatief on 27/12/2024.
//

import SwiftUI



struct LaunchView: View {
    // MARK: - PROPERTIES
    @State private var textVisible = false
    @State private var showLibrary = false
    @State private var noteOffset: CGFloat = 250
    
    var body: some View {
        // MARK: - LOGO
        HStack {
            Image(systemName: "music.note")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue, Color.gray],
                        startPoint: .leading,
                        endPoint: .trailing)
                )
                .offset(x: noteOffset)
                .animation(
                    .easeOut(duration: 0.9),
                    value: noteOffset
                )
            
            
            
            
            Text("Gesturetunes")
                .font(.system(size: 35, weight: .bold))
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
            
        }
        .onAppear {
            // Start the music note animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                noteOffset = -0.5 // Adjust the value as needed for desired movement
            }
            
            // Trigger the text animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                textVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                showLibrary = true
            }
            
        }
        .fullScreenCover(isPresented: $showLibrary) {
            Library()
                .environmentObject(MusicPlayerController(songs: Song.mockPlaylist()))
        }
        
    }
}

#Preview {
    LaunchView()
}
