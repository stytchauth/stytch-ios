import StytchCore
import SwiftUI

struct LUDSIndicator: View {
    @ObservedObject var state = LUDSFeedbackState()

    @ViewBuilder var body: some View {
        if let feedback = state.feedback {
            let validLength = feedback.missingCharacters == 0
            let validComplexity = feedback.missingComplexity == 0
            let lengthColor = validLength ? Color(.progressSuccess) : Color(.dangerText)
            let complexityColor = validComplexity ? Color(.progressSuccess) : Color(.dangerText)
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 4) {
                    if validLength {
                        Image("checkIcon", bundle: .module).frame(width: 16, height: 16, alignment: .center)
                    } else {
                        Image("crossIcon", bundle: .module).frame(width: 16, height: 16, alignment: .center)
                    }
                    Text("Must be at least \(state.passwordConfig?.ludsMinimumCount ?? 0) characters long")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(Font(UIFont.IBMPlexSansRegular(size: 16)))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(lengthColor)
                }
                HStack(alignment: .center, spacing: 4) {
                    if validComplexity {
                        Image("checkIcon", bundle: .module).frame(width: 16, height: 16, alignment: .center)
                    } else {
                        Image("crossIcon", bundle: .module).frame(width: 16, height: 16, alignment: .center)
                    }
                    Text("Must contain \(state.passwordConfig?.ludsComplexity ?? 0) of the following: uppercase letter, lowercase letter, number, symbol")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(Font(UIFont.IBMPlexSansRegular(size: 16)))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(complexityColor)
                }
                if state.breached {
                    Image("crossIcon", bundle: .module).frame(width: 16, height: 16, alignment: .center)
                    HStack(alignment: .center, spacing: 4) {
                        Text("This password may have been used on a different site that experienced a security issue. Please choose another password.")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(Font(UIFont.IBMPlexSansRegular(size: 16)))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(.dangerText))
                    }
                }
            }
        }
    }

    func setFeedback(feedback: LudsRequirement?, breached: Bool = false, passwordConfig: PasswordConfig? = nil) {
        state.feedback = feedback
        state.breached = breached
        state.passwordConfig = passwordConfig
    }
}

final class LUDSFeedbackState: ObservableObject {
    @Published var feedback: LudsRequirement?
    @Published var breached: Bool = false
    @Published var passwordConfig: PasswordConfig?
}
