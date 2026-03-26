//
//  AudioPlayerView.swift
//  App
//
//  Created by John Hanna on 3/20/26.
//
import SwiftUI
import AVKit
import Combine
import MediaPlayer


struct AudioPlayerView: View {
    let file: DriveFile
    let appFontSize: Double

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1
    @State private var playbackRate: Float = 1.0

    private var streamURL: URL? {
        URL(string: "https://drive.google.com/uc?export=download&id=\(file.id)")
    }

    var body: some View {
        VStack(spacing: 30) {
            Text(file.name)
                .font(.system(size: appFontSize, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.top)

            VStack {
                Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                    if !editing {
                        let time = CMTime(seconds: currentTime, preferredTimescale: 600)
                        player?.seek(to: time)
                    }
                })

                HStack {
                    Text(formatTime(currentTime))
                    Spacer()
                    Text(formatTime(duration))
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding(.horizontal)

            HStack(spacing: 40) {
                Button { seek(by: -15) } label: {
                    Image(systemName: "gobackward.15").font(.title2)
                }

                Button { togglePlay() } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }

                Button { seek(by: 15) } label: {
                    Image(systemName: "goforward.15").font(.title2)
                }
            }

            HStack(spacing: 16) {
                Text("Speed")
                    .font(.system(size: appFontSize))

                ForEach([0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { rate in
                    Button {
                        setPlaybackRate(rate)
                    } label: {
                        Text(String(format: "%.2gx", rate))
                            .font(.system(size: appFontSize * 0.9))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(playbackRate == Float(rate) ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(6)
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Now Playing")
        .onAppear { setupPlayer() }
        .onDisappear { player?.pause() }
    }

    // MARK: - Setup Player

    private func setupPlayer() {
        guard let url = streamURL else { return }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        let newPlayer = AVPlayer(url: url)
        player = newPlayer

        if let item = newPlayer.currentItem {
            Task {
                let durationTime = try? await item.asset.load(.duration)
                let seconds = CMTimeGetSeconds(durationTime ?? .zero)
                if seconds.isFinite {
                    await MainActor.run { self.duration = seconds }
                }
            }
        }

        setupRemoteControls()
        addTimeObserver()

        newPlayer.play()
        isPlaying = true
        updateNowPlaying()
    }

    // MARK: - Now Playing

    private func updateNowPlaying() {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: (file.name as NSString).deletingPathExtension,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let image = UIImage(systemName: "music.note") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Remote Controls

    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            player?.play()
            isPlaying = true
            updateNowPlaying()
            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            player?.pause()
            isPlaying = false
            updateNowPlaying()
            return .success
        }
            commandCenter.changePlaybackPositionCommand.isEnabled = true

            commandCenter.changePlaybackPositionCommand.addTarget { event in
                guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                    return .commandFailed
                }

                let time = CMTime(seconds: event.positionTime, preferredTimescale: 600)
                player?.seek(to: time)

                currentTime = event.positionTime
                updateNowPlaying()

                return .success
            }
    }

    // MARK: - Controls

    private func togglePlay() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.rate = playbackRate
        }
        isPlaying.toggle()
        updateNowPlaying()
    }

    private func setPlaybackRate(_ rate: Double) {
        playbackRate = Float(rate)
        player?.rate = isPlaying ? playbackRate : 0
    }

    private func seek(by seconds: Double) {
        guard let player = player else { return }
        let newTime = max(0, min(currentTime + seconds, duration))
        let time = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: time)
    }

    private func addTimeObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = time.seconds
            updateNowPlaying()
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
