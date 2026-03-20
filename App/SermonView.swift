import SwiftUI

struct SermonView: View {

    let video: YouTubeVideo
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {

        ScrollView {
            VStack(spacing: 16) {

                YouTubePlayer(videoID: video.videoId)
                    .frame(height: 250)
                    .cornerRadius(12)
                    .padding(.horizontal)

                Text(video.title)
                    .font(.system(size: appFontSize + 4, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .textSelection(.enabled)

                Spacer(minLength: 20)
            }
            .padding(.top)
        }
        .navigationTitle("Sermon")
        .navigationBarTitleDisplayMode(.inline)
    }
}
