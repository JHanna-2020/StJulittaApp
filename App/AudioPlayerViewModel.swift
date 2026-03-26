
import Foundation
import AVKit
import MediaPlayer

@MainActor
class AudioPlayerViewModel: ObservableObject {

    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0.1
    @Published var playbackRate: Float = 1.0

    private var player: AVPlayer?
    private var timeObserver: Any?

    // MARK: - Setup

    func setup(url: URL) {
        configureAudioSession()

        let player = AVPlayer(url: url)
        self.player = player

        setupDuration()
        setupRemoteControls()
        addTimeObserver()

        player.play()
        isPlaying = true
        updateNowPlaying()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    private func setupDuration() {
        guard let item = player?.currentItem else { return }

        Task {
            let durationTime = try? await item.asset.load(.duration)
            let seconds = CMTimeGetSeconds(durationTime ?? .zero)
            if seconds.isFinite {
                self.duration = seconds
            }
        }
    }

    // MARK: - Controls

    func togglePlay() {
        guard let player = player else { return }

        if isPlaying {
            player.pause()
        } else {
            player.playImmediately(atRate: playbackRate)
        }

        isPlaying.toggle()
        updateNowPlaying()
    }

    func setPlaybackRate(_ rate: Double) {
        playbackRate = Float(rate)
        player?.rate = isPlaying ? playbackRate : 0
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
    }

    func seek(by seconds: Double) {
        let newTime = max(0, min(currentTime + seconds, duration))
        seek(to: newTime)
    }

    // MARK: - Time Observer

    private func addTimeObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            self?.updateNowPlaying()
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    // MARK: - Remote Controls

    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.changePlaybackPositionCommand.removeTarget(nil)

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            self?.isPlaying = true
            self?.updateNowPlaying()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            self?.isPlaying = false
            self?.updateNowPlaying()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            self?.seek(to: event.positionTime)
            return .success
        }
    }

    // MARK: - Now Playing

    private func updateNowPlaying() {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: "Now Playing",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? playbackRate : 0.0
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Cleanup

    func cleanup() {
        player?.pause()
        removeTimeObserver()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}
