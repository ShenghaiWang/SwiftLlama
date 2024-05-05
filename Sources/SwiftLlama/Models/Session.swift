import Foundation

struct Session {
    var history: [Chat] = []
    var prompt: Prompt
    var currentResponse: String = ""

    init(history: [Chat] = [], prompt: Prompt) {
        self.history = history
        self.prompt = prompt
    }

    mutating func endRespose() {
        history.append(Chat(user: prompt.userMessage, bot: currentResponse))
        currentResponse = ""
    }

    mutating func response(delta: String) {
        currentResponse += delta
    }

    var sessionPrompt: Prompt {
        Prompt(type: prompt.type, userMessage: prompt.userMessage, history: history)
    }
}
