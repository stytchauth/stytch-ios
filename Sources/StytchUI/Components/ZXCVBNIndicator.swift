import SwiftUI
import StytchCore

private let MAX_SCORE = 3

struct ZXCVBNIndicator: View {
    @ObservedObject var state = ZXCVBNState()
    
    public func setFeedback(
        suggestions: [String]? = nil,
        warning: String? = nil,
        score: Int = 0
    ) {
        state.suggestions = suggestions
        state.warning = warning
        state.score = score
    }
    
    var body: some View {
        let emptyColor = UIColor.progressDefault
        let filledColor = if (state.score < MAX_SCORE) {
            UIColor.progressDanger
        } else {
            UIColor.progressSuccess
        }
        let text = if (state.score < MAX_SCORE) {
            (state.suggestions ?? []).joined(separator: ", ")
        } else {
            "Great job! This is a strong password."
        }
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                ForEach((0...MAX_SCORE), id: \.self) { index in
                    let color = if (state.score >= index) {
                        filledColor
                    } else {
                        emptyColor
                    }
                    Rectangle().fill(Color(color)).frame(height: 4)
                }
            }
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
                .font(Font(UIFont.IBMPlexSansRegular(size: 16)))
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(filledColor))
        }
    }
}

final class ZXCVBNState: ObservableObject {
    @Published var score: Int = 0
    @Published var suggestions: [String]? = nil
    @Published var warning: String? = nil
}
