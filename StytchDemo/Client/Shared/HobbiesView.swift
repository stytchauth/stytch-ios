import SwiftUI
import StytchCore

struct HobbiesView: View {
    @StateObject private var model: Model = .init()

    @State private var newHobbyName: String = ""

    var body: some View {
        VStack {
            Text("Hobbies")
                .font(.title2)
            List {
                Section("Favorite hobbies") {
                    ForEach(model.hobbies.filter(\.favorited)) { hobby in
                        HobbyView(hobby: hobby, onUpdate: model.update(hobby:))
                    }
                    .onDelete { $0.forEach(model.deleteHobby(at:)) }
                }
                Section("Other hobbies") {
                    ForEach(model.hobbies.filter { !$0.favorited }) { hobby in
                        HobbyView(hobby: hobby, onUpdate: model.update(hobby:))
                    }
                    .onDelete { $0.forEach(model.deleteHobby(at:)) }
                }
                Section("Add a new hobby") {
                    HStack {
                        TextField("Hobby name", text: $newHobbyName)
                            .onSubmit {
                                guard !newHobbyName.isEmpty else { return }
                                model.addHobby(name: newHobbyName) { newHobbyName = $0 }
                                newHobbyName = ""
                            }
                        Button("Add hobby") {
                            model.addHobby(name: newHobbyName) { newHobbyName = $0 }
                            newHobbyName = ""
                        }
                            .disabled(newHobbyName.isEmpty)
                    }
                }
            }
        }
        .task { model.fetch() }
    }
}

struct HobbyView: View {
    let hobby: Hobby

    let onUpdate: (Hobby) -> Void

    var body: some View {
        HStack {
            Text(hobby.name)
            Button(
                action: {
                    var hobby = self.hobby
                    hobby.favorited.toggle()
                    onUpdate(hobby)
                },
                label: { Image(systemName: hobby.favorited ? "heart.fill" : "heart") }
            )
        }
    }
}

struct Hobby: Codable, Identifiable {
    let id: UUID
    var name: String
    var favorited: Bool
}

struct HobbyList: Codable {
    let userId: String
    var hobbies: [Hobby]
}

extension HobbiesView {
    final class Model: ObservableObject {
        @Published var hobbies: [Hobby] = []

        func fetch() {
            Task {
                do {
                    let hobbyList: HobbyList = try await performRequest(request(url: hobbiesUrl))
                    DispatchQueue.main.async {
                        self.hobbies = hobbyList.hobbies
                    }
                } catch {}
            }
        }

        func update(hobby: Hobby) {
            guard let index = hobbies.firstIndex(where: { $0.id == hobby.id }) else {
                return
            }
            let oldHobby = hobbies[index]
            self.hobbies[index] = hobby
            Task {
                var request = request(url: hobbyUrl(hobby), method: "PUT")
                do {
                    request.httpBody = try JSONEncoder().encode(hobby)
                    let updatedHobby: Hobby = try await performRequest(request)
                    DispatchQueue.main.async {
                        self.hobbies[index] = updatedHobby
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.hobbies[index] = oldHobby
                    }
                }
            }
        }

        func addHobby(name: String, onFailure: @escaping (String) -> Void) {
            let tempHobby = Hobby(id: .init(), name: name, favorited: false)
            hobbies.append(tempHobby)
            Task {
                var request = request(url: hobbiesUrl.appendingPathComponent("new"), method: "POST")
                let updateHobby: (Hobby?) -> Void = { [weak self] hobby in
                    guard let self = self else { return }
                    guard let index = self.hobbies.firstIndex(where: { $0.id == tempHobby.id }) else {
                        hobby.map { self.hobbies.append($0) }
                        return
                    }
                    if let hobby = hobby {
                        self.hobbies[index] = hobby
                    } else {
                        self.hobbies.remove(at: index)
                    }
                }
                do {
                    struct HobbyParams: Encodable {
                        let name: String
                    }
                    request.httpBody = try JSONEncoder().encode(HobbyParams(name: name))
                    let updatedHobby: Hobby = try await performRequest(request)
                    DispatchQueue.main.async {
                        updateHobby(updatedHobby)
                    }
                } catch {
                    DispatchQueue.main.async {
                        updateHobby(nil)
                        onFailure(name)
                    }
                }
            }
        }

        func deleteHobby(at index: Int) {
            let hobby = hobbies.remove(at: index)
            let revertRemoval = {
                DispatchQueue.main.async {
                    self.hobbies.insert(hobby, at: index)
                }
            }
            Task {
                do {
                    struct Response: Decodable {
                        let success: Bool
                    }
                    let request = request(url: hobbyUrl(hobby), method: "DELETE")
                    if case let response: Response = try await performRequest(request), !response.success {
                        revertRemoval()
                    }
                } catch {
                    revertRemoval()
                }
            }
        }

        private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        }

        private func request(url: URL, method: String? = nil) -> URLRequest {
            var request: URLRequest = .init(url: url)
            if let method = method {
                request.httpMethod = method
            }
            StytchClient.sessions.sessionToken.map { request.addValue($0.value, forHTTPHeaderField: "X-Stytch-Token") }
            return request
        }

        private var hobbiesUrl: URL { configuration.serverUrl.appendingPathComponent("hobbies") }

        private func hobbyUrl(_ hobby: Hobby) -> URL {
            hobbiesUrl.appendingPathComponent(hobby.id.uuidString)
        }
    }
}
