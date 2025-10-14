import Vapor
import AlpacaMarketDataHub

@main
struct AppMain {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let serverConfig = try ServerConfig.load(configFile: "/opt/zeple/trade/serverconfig.json")
        
        let app = try await Application.make(env)
        defer {
            Task {
                try await app.asyncShutdown()
            }
        }

        let alpacaAccount = serverConfig.alpacapaperaccount
        //let alpacaAccount = serverConfig.alpacaliveaccount
        
        let alpacaHub = AlpacaMarketDataHub(alpaca: .init(apiKey: alpacaAccount.alpaca_api_key, apiSecret: alpacaAccount.alpaca_api_secret, feed: .iex_extended))
        try configure(app, alpacaHub)
        try await alpacaHub.start()

        // Runs the server and suspends this task until shutdown (SIGINT/SIGTERM).
        try await app.execute()
    }
}
