import SwiftUI

struct PasswordView: View {
    let title: String
    let onSubmit: () -> Void
    let onDebouncedInteraction: () -> Void
    let isSecure: Bool
    @Binding var password: String
    var publisher: Published<String>.Publisher

    var body: some View {
        (
            isSecure ?
                AnyView(SecureField(text: $password, label: { Text(title) })) :
                AnyView(TextField(text: $password, label: { Text(title) }))
        )
        .onReceive(
            publisher
                .map { _ in }
                .dropFirst()
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main),
            perform: onDebouncedInteraction
        )
        .onSubmit(onSubmit)
        .padding(.horizontal)
        .textFieldStyle(.roundedBorder)
        .disableAutocorrection(true)
        #if !os(macOS)
            .textInputAutocapitalization(.never)
            .textContentType(.password)
        #endif
    }
}
