import Foundation

class Message {
    var timestamp: String;
    var name: String;
    var message: String;
    
    init(timestamp: String, name: String, message: String) {
        self.timestamp = timestamp;
        self.name = name
        self.message = message
    }
    
}
