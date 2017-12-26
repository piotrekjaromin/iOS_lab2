import Foundation

class Message {
    var timestamp: Int;
    var name: String;
    var message: String;
    
    init(timestamp: Int, name: String, message: String) {
        self.timestamp = timestamp;
        self.name = name
        self.message = message
    }
    
}
