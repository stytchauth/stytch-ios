import SwiftUI

struct PasswordFeedbackView: View {
    let strength: Double?
    let warning: String
    let feedback: String

    var body: some View {
        VStack {
            if let strength = strength {
                ProgressView("Password Strength", value: strength)
                    .tint(strength <= 0.5 ? .red : .green)
                    .padding(.horizontal)
            }
            if !warning.isEmpty {
                Text(warning)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            if !feedback.isEmpty {
                Text(feedback)
                    .padding()
            }
        }
    }
}
