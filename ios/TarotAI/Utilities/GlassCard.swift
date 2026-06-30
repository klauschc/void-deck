import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.clear)
                    .glassEffect(.regular.interactive())
            }
    }
}

struct GlassCardButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    var body: some View {
        Button(action: action) {
            content
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.clear)
                        .glassEffect(.regular.interactive())
                }
        }
    }
}
