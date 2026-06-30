import SwiftUI

struct CardOrientationPicker: View {
    @Binding var orientation: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                TarotTheme.cosmicBg
                VStack(spacing: 24) {
                    Text("選擇牌位方向").font(.title2).foregroundStyle(.white)
                    Picker("方向", selection: $orientation) {
                        Text("正位 Upright").tag("upright")
                        Text("逆位 Reversed").tag("reversed")
                    }
                    .pickerStyle(.segmented)
                    .tint(TarotTheme.primaryStart)
                    .padding(.horizontal, 40)
                    Button("確定") { dismiss() }.buttonStyle(.borderedProminent).tint(TarotTheme.primaryStart)
                }
            }
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } } }
        }
    }
}
