extension StytchClient.MagicLinks {
    public struct Email {
        let pathContext: String

        var send: StytchTask<EmailParameters, EmailResponse> {
            fatalError("do i need this??")
        }

        var loginOrCreate: StytchTask<EmailParameters, EmailResponse> {
            StytchTask { parameters, completion in
                StytchClient.instance.post(
                    parameters: parameters,
                    path: "\(pathContext)/login_or_create",
                    completion: completion
                )
            }
        }

        init(pathContext: String) {
            self.pathContext = String(pathContext.drop(while: { $0 == "/" })) + "/email"
        }
    }
}
