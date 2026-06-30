import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    
    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            if viewModel.readings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "moon.stars").font(.largeTitle).foregroundStyle(TarotTheme.accent)
                    Text("尚無占卜紀錄").foregroundStyle(.white)
                }
            } else {
                List(viewModel.readings) { reading in
                    NavigationLink(value: reading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reading.question).font(.headline).foregroundStyle(.white).lineLimit(1)
                            Text(reading.createdAt ?? "").font(.caption).foregroundStyle(TarotTheme.accent)
                        }
                    }.listRowBackground(Color.clear)
                }.scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("占卜紀錄")
        .task { await viewModel.loadReadings() }
    }
}
