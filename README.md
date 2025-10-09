#  alpaca-market-stream-server

* An websocket client connected to alpaca's market data stream server.
* Subscribe for all the App clients, when receive a data, send to app client who subscribes it.
* each App clients establish a websocket to this server.
* all the subscription send from app client to this server should contains all the stock symbols, send a empty array will unsubscribe all. There is no specific unsubscribe commands, which is different from how the alpaca's steam server works. 


