import StytchUI
import SwiftUI

struct ContentView: View {
    @State private var authPresented = true
    var config: StytchUIClient.Configuration

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .authenticationSheet(
            isPresented: $authPresented,
            config: config
        )
    }
}

#Preview {
    ContentView(config: .realisticStytchUIConfig)
}
