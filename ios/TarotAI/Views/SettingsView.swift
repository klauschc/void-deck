import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var showSaved = false

    var body: some View {
        ZStack {
            TarotTheme.cosmicBg
            VStack(spacing: 16) {
                GlassCard(VStack(alignment: .leading, spacing: 8) {
                    Text("API Base URL").font(.caption).foregroundStyle(TarotTheme.accent)
                    TextField("http://localhost:8000", text: $viewModel.baseURL).foregroundStyle(.white).textContentType(.URL).keyboardType(.URL).autocapitalization(.none)
                })
                GlassCard(VStack(alignment: .leading, spacing: 8) {
                    Text("API Key").font(.caption).foregroundStyle(TarotTheme.accent)
                    SecureField("nvapi-...", text: $viewModel.apiKey).foregroundStyle(.white).autocapitalization(.none)
                })
                GlassCard(VStack(alignment: .leading, spacing: 8) {
                    Text("Model").font(.caption).foregroundStyle(TarotTheme.accent)
                    TextField("minimaxai/minimax-m3", text: $viewModel.model).foregroundStyle(.white).autocapitalization(.none)
                })
                Button {
                    viewModel.save()
                    showSaved = true
                    APIClient.shared.reconfigure()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showSaved = false }
                } label: {
                    Text(showSaved ? "已儲存！" : "儲存設定").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 14).background(showSaved ? AnyShapeStyle(Color.green) : AnyShapeStyle(TarotTheme.primaryGradient)).clipShape(Capsule())
                }.disabled(viewModel.baseURL.isEmpty)
                Spacer()
            }.padding()
        }
        .navigationTitle("設定")
    }
}
