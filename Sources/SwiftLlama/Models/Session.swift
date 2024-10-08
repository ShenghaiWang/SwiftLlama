import Foundation

struct Session {
    private var history: [Chat] = []
    var lastPrompt: Prompt
    var currentResponse: String = ""

    init(history: [Chat] = [], lastPrompt: Prompt) {
        self.history = history
        self.lastPrompt = lastPrompt
    }

    mutating func endResponse() {
        history.append(Chat(user: lastPrompt.userMessage, bot: currentResponse))
        currentResponse = ""
    }

    mutating func response(delta: String) {
        currentResponse += delta
    }

    var sessionPrompt: Prompt {
        Prompt(type: lastPrompt.type,
               systemPrompt: lastPrompt.systemPrompt,
               userMessage: lastPrompt.userMessage,
               history: history)
    }
}
