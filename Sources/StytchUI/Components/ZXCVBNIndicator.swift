import StytchCore
import SwiftUI

private let MAXSCORE = 3

struct ZXCVBNIndicator: View {
    @ObservedObject var state = ZXCVBNState()

    var body: some View {
        let emptyColor = UIColor.progressDefault
        let filledColor: UIColor = state.score < MAXSCORE ? UIColor.progressDanger : UIColor.progressSuccess
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                ForEach(0...MAXSCORE, id: \.self) { index in
                    let color = state.score >= index ? filledColor : emptyColor
                    Rectangle().fill(Color(color)).frame(height: 4)
                }
            }
            if state.score < MAXSCORE {
                if let warning = state.warning, !warning.isEmpty {
                    HStack(alignment: .center, spacing: 4) {
                        Image("crossIcon", bundle: .module).frame(width: 16, height: 16, alignment: .center)
                        Text(warning.mapToLocalizedString())
                            .fixedSize(horizontal: false, vertical: true)
                            .font(Font(UIFont.IBMPlexSansRegular(size: 16)))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(filledColor))
                    }
                }
                ForEach(state.suggestions ?? [], id: \.self) { suggestion in
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("•")
                            .frame(width: 16, height: 16, alignment: .center)
                            .font(Font(UIFont.IBMPlexSansRegular(size: 16)))
                            .foregroundColor(Color(UIColor.secondaryText))
                        Text(suggestion.mapToLocalizedString())
                            .fixedSize(horizontal: false, vertical: true)
                            .font(Font(UIFont.IBMPlexSansRegular(size: 16)))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(UIColor.secondaryText))
                    }
                }
            } else {
                Text(LocalizationManager.stytch_zxcvbn_feedback_success)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(Font(UIFont.IBMPlexSansRegular(size: 16)))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(filledColor))
            }
        }
    }

    func setFeedback(
        suggestions: [String]? = nil,
        warning: String? = nil,
        score: Int = 0
    ) {
        state.suggestions = suggestions
        state.warning = warning
        state.score = score
    }
}

final class ZXCVBNState: ObservableObject {
    @Published var score: Int = 0
    @Published var suggestions: [String]?
    @Published var warning: String?

    init(score: Int = 0, suggestions: [String]? = nil, warning: String? = nil) {
        self.score = score
        self.suggestions = suggestions
        self.warning = warning
    }
}

private extension String {
    func mapToLocalizedString() -> String {
        switch self {
        case "Use a few words, avoid common phrases.":
            LocalizationManager.stytch_zxcvbn_suggestion_1
        case "No need for symbols, digits, or uppercase letters.":
            LocalizationManager.stytch_zxcvbn_suggestion_2
        case "Add another word or two. Uncommon words are better.":
            LocalizationManager.stytch_zxcvbn_suggestion_3
        case "Use a longer keyboard pattern with more turns.":
            LocalizationManager.stytch_zxcvbn_suggestion_4
        case "Avoid repeated words and characters.":
            LocalizationManager.stytch_zxcvbn_suggestion_5
        case "Avoid sequences.":
            LocalizationManager.stytch_zxcvbn_suggestion_6
        case "Avoid recent years.":
            LocalizationManager.stytch_zxcvbn_suggestion_7
        case "Avoid years that are associated with you.":
            LocalizationManager.stytch_zxcvbn_suggestion_8
        case "Avoid dates and years that are associated with you.":
            LocalizationManager.stytch_zxcvbn_suggestion_9
        case "Capitalization doesn\'t help very much.":
            LocalizationManager.stytch_zxcvbn_suggestion_10
        case "All-uppercase is almost as easy to guess as all-lowercase.":
            LocalizationManager.stytch_zxcvbn_suggestion_11
        case "Reversed words aren\'t much harder to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_12
        case "Predictable substitutions like \'@\' instead of \'a\' don\'t help very much.":
            LocalizationManager.stytch_zxcvbn_suggestion_13
        case "Short keyboard patterns are easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_14
        case "Straight rows of keys are easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_15
        case "Repeats like \"abcabcabc\" are only slightly harder to guess than \"abc\".":
            LocalizationManager.stytch_zxcvbn_suggestion_16
        case "Repeats like \"aaa\" are easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_17
        case "Sequences like \"abc\" or \"6543\" are easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_18
        case "Recent years are easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_19
        case "Dates are often easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_20
        case "This is a top-10 common password.":
            LocalizationManager.stytch_zxcvbn_suggestion_21
        case "This is a top-100 common password.":
            LocalizationManager.stytch_zxcvbn_suggestion_22
        case "This is a very common password.":
            LocalizationManager.stytch_zxcvbn_suggestion_23
        case "This is similar to a commonly used password.":
            LocalizationManager.stytch_zxcvbn_suggestion_24
        case "A word by itself is easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_25
        case "Names and surnames by themselves are easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_26
        case "Common names and surnames are easy to guess.":
            LocalizationManager.stytch_zxcvbn_suggestion_27
        default:
            self
        }
    }
}

#Preview {
    let state: ZXCVBNState = .init(
        score: 2,
        suggestions: [
            "Predictable substitutions like \'@\' instead of \'a\' don\'t help very much.",
            "Common names and surnames are easy to guess."
        ],
        warning: "Common names and surnames are easy to guess."
    )
    ZXCVBNIndicator(state: state)
}
