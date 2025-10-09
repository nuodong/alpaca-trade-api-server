import Vapor

@main
struct AppMain {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let app = try await Application.make(env)
        defer {
            Task {
                try await app.asyncShutdown()
            }
        }

        let alpacaHub = WebSocketHub(alpaca: .init(apiKey: "PKK5J916VK887J82WPMF", apiSecret: "bTEAEeC7XCXiEgYhjmDvjntAsWRTCa7ayDcqnqZc", feed: .iex_extended))
        try configure(app, alpacaHub)
        try await alpacaHub.start()

        // Runs the server and suspends this task until shutdown (SIGINT/SIGTERM).
        try await app.execute()
    }
}
