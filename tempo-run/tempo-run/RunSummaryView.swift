import SwiftUI

struct RunSummaryView: View {
    let playedSongs: [(song: String, pace: Double)]
    @Environment(\.dismiss) private var dismiss

    var averagePace: Double {
        let total = playedSongs.reduce(0) { $0 + $1.pace }
        return playedSongs.isEmpty ? 0 : total / Double(playedSongs.count)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("🏆 Average Pace")
                .font(.title2)

            Text("\(String(format: "%.2f", averagePace)) min/km")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.blue)

            Divider()

            List(playedSongs, id: \.song) { song in
                VStack(alignment: .leading) {
                    Text(song.song)
                        .font(.headline)
                    Text("Pace: \(String(format: "%.2f", song.pace)) min/km")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: {
                dismiss()
            }) {
                Text("🏠 Back to Home")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

