import Testing
@testable import alpaca_market_stream_server

@Test func example() async throws {
    let client = AlpacaMarketWebsocketClient(apiKey: "PKK5J916VK887J82WPMF", apiSecret: "bTEAEeC7XCXiEgYhjmDvjntAsWRTCa7ayDcqnqZc", feed: .iex_extended)
    await client.start(onConnect:  { //connected and authorized
        print("***** onConnect")
        Task {
            //let sub = #"{"action":"subscribe","trades":["AAPL"],"quotes":["AAPL"],"bars": ["AAPL"]}"#
            var sub = #"{"action":"subscribe", "bars": ["AAPL", "FFAI"]}"#
            try await client.send(sub)
            
            try await Task.sleep(for: .seconds(1))
            sub = #"{"action":"subscribe","bars": ["AMD"]}"#
            try await client.send(sub)
            
            try await Task.sleep(for: .seconds(1))
            sub = #"{"action":"subscribe","bars": ["BABA"]}"#
            try await client.send(sub)
            
            try await Task.sleep(for: .seconds(1))
            sub = #"{"action":"subscribe","trades": ["BABA"], "quotes": ["BABA"], "bars": ["BABA","FFAI"]}"#
            try await client.send(sub)
            
            try await Task.sleep(for: .seconds(1))
            sub = #"{"action":"subscribe","trades": ["JD"]}"#
            try await client.send(sub)
            
            try await Task.sleep(for: .seconds(1))
            sub = #"{"action":"unsubscribe","trades": ["JD"]}"#
            try await client.send(sub)
            
            try await Task.sleep(for: .seconds(1))
            print("subscribe a not exist trade will add the trade in it")
            sub = #"{"action":"subscribe","trades": ["SUBNOTEXISTONE"]}"#
            try await client.send(sub)
            
            try await Task.sleep(for: .seconds(1))
            print("unsubscribe a not exist trade will be ignored")
            sub = #"{"action":"unsubscribe","trades": ["UNSUBNOTEXISTONE"]}"#
            try await client.send(sub)
            
//            for _ in 0...100 {
//                sub = #"{"action":"unsubscribe","trades": ["UNSUBNOTEXISTONE"]}"#
//                try await client.send(sub)
//                try await Task.sleep(for: .seconds(1))
//            }
        }
        
    }, onDisconnect: {
        print("***** disConnect")
    }, onReceiveMarketData: { messages in
        print("***** onReceiveMarketData")
    })
    
    //wait for a while
    try await Task.sleep(for: .seconds(100))
    print("example usage ends correctly")
}
