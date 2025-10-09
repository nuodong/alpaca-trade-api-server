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

        try configure(app)

        // Runs the server and suspends this task until shutdown (SIGINT/SIGTERM).
        try await app.execute()
    }
}
