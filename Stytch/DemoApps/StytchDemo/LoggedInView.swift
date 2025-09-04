import StytchCore
import SwiftUI

struct LoggedInView: View {
    @State var userName = StytchClient.user.getSync()?.name.fullName ?? ""
    @State var inputText: String = ""
    @State var errorMessage = ""
    @State var didLogOut = false
    @State var showAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Session Token:").bold()
            Text(StytchClient.sessions.sessionToken?.value ?? "").font(.footnote)
            Spacer().frame(height: 20)

            Text("Session Expires:").bold()
            Text(StytchClient.sessions.session?.expiresAt.formatted(date: .abbreviated, time: .shortened) ?? "").font(.footnote)
            Spacer().frame(height: 20)

            Text("User Id:").bold()
            Text(StytchClient.user.getSync()?.id.rawValue ?? "").font(.footnote)
            Spacer().frame(height: 20)

            Text("User Name:").bold()
            Text(userName).font(.footnote)
            Spacer().frame(height: 20)

            Button("Log Out") {
                logOut()
            }
            .padding()
            .frame(height: 40)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            Spacer().frame(height: 20)

            HStack {
                TextField("Update User Name", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Submit") {
                    updateUserName()
                }
                .padding()
                .frame(height: 40)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                showAlert = false
            }
        } message: {
            Text(errorMessage)
        }
        .padding([.leading, .trailing], 20)
        .id(didLogOut)
    }

    func updateUserName() {
        Task {
            do {
                let newName = User.Name(inputText)
                let parameters = StytchClient.UserManagement.UpdateParameters(name: newName)
                let response = try await StytchClient.user.update(parameters: parameters)
                userName = response.user.name.fullName
            } catch {
                showErrorAlert(error)
            }
        }
    }

    func logOut() {
        Task {
            do {
                _ = try await StytchClient.sessions.revoke()
                didLogOut = true
            } catch {
                showErrorAlert(error)
            }
        }
    }

    func showErrorAlert(_ error: Error) {
        inputText = ""
        showAlert = true
        errorMessage = error.errorInfo
    }
}

#Preview {
    LoggedInView()
}
