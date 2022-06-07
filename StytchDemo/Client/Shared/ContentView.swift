import StytchCore
import SwiftUI

struct ContentView: View {
    var sessionUser: (Session, User)?
    let logOutTapped: () -> Void
    let onAuth: (Session, User) -> Void
    @State private var presentationOption: PresentationOption?

    var body: some View {
        NavigationView {
            if let sessionUser = sessionUser {
                VStack(spacing: 12) {
                    Spacer()
                    Text("Welcome, \(sessionUser.1.name.firstName.presence ?? "pal")!")
                        .font(.title)
                    Spacer()
                    Button("View hobbies") {
                        presentationOption = .hobbies
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Add or refresh auth factor") {
                        presentationOption = .authOptions
                    }
                    Button("View session info") {
                        presentationOption = .sessionInfo
                    }
                    Spacer()
                }
                .navigationTitle("Stytch Demo")
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Log out", action: logOutTapped)
                    }
                }
                .sheet(item: $presentationOption) { option in
                    Group {
                        switch option {
                        case .authOptions:
                            NavigationView {
                                AuthenticationOptionsView(session: sessionUser.0, onAuth: onAuth)
                                    .frame(minWidth: 200, minHeight: 200)
                                    .toolbar {
                                        ToolbarItem(placement: .cancellationAction) {
                                            Button("Cancel") { presentationOption = nil }
                                        }
                                    }
                            }
                        case .sessionInfo:
                            #if !os(macOS)
                            NavigationView {
                                SessionView(sessionUser: sessionUser)
                                    .frame(minWidth: 200, minHeight: 200)
                                    .toolbar {
                                        ToolbarItem(placement: .cancellationAction) {
                                            Button("Cancel") { presentationOption = nil }
                                        }
                                    }
                            }
                            #else
                            SessionView(sessionUser: sessionUser)
                                .frame(minWidth: 400, minHeight: 400)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Cancel") { presentationOption = nil }
                                    }
                                }
                            #endif
                        case .hobbies:
                            #if !os(macOS)
                            NavigationView {
                                HobbiesView()
                                    .toolbar {
                                        ToolbarItem(placement: .cancellationAction) {
                                            Button("Cancel") { presentationOption = nil }
                                        }
                                    }
                            }
                            #else
                            HobbiesView()
                                .frame(minWidth: 400, minHeight: 400)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Cancel") { presentationOption = nil }
                                    }
                                }
                            #endif
                        }
                    }
                }
                #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
            } else {
                AuthenticationOptionsView(session: sessionUser?.0, onAuth: onAuth)
                    .navigationTitle("Stytch Demo")
                #if !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
            }
        }
    }

    enum PresentationOption: String, Identifiable {
        var id: String { rawValue }

        case sessionInfo
        case authOptions
        case hobbies
    }
}
