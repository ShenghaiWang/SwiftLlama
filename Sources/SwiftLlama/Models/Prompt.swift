import Foundation

public struct Prompt {
    public enum `Type` {
        case chatML
        case alpaca
        case llama
        case llama3
        case mistral
        case phi
    }

    public let type: `Type`
    public let systemPrompt: String
    public let userMessage: String
    public let history: [Chat]

    public init(type: `Type`,
                systemPrompt: String = "",
                userMessage: String,
                history: [Chat] = []) {
        self.type = type
        self.systemPrompt = systemPrompt
        self.userMessage = userMessage
        self.history = history
    }

    var prompt: String {
        switch type {
        case .llama: encodeLlamaPrompt()
        case .llama3: encodeLlama3Prompt()
        case .alpaca: encodeAlpacaPrompt()
        case .chatML: encodeChatMLPrompt()
        case .mistral: encodeMistralPrompt()
        case .phi: encodePhiPrompt()
        }
    }

    private func encodeLlamaPrompt() -> String {
        """
        [INST]<<SYS>>
        \(systemPrompt)
        <</SYS>>
        \(history.last?.llamaPrompt ?? "")
        [/INST]
        [INST]
        \(userMessage)
        [/INST]
        """
    }

    private func encodeLlama3Prompt() -> String {
        """
        <|start_header_id|>system<|end_header_id|>

        \(systemPrompt)<|eot_id|>
        \(history.last?.llama3Prompt ?? "")
        <|start_header_id|>user<|end_header_id|>
        
        \(userMessage)
        <|eot_id|><|start_header_id|>assistant<|end_header_id|>
        """
    }

    private func encodeAlpacaPrompt() -> String {
        """
        Below is an instruction that describes a task.
        Write a response that appropriately completes the request.
        \(userMessage)
        """
    }

    private func encodeChatMLPrompt() -> String {
        """
        \(systemPrompt)
        \(history.last?.chatMLPrompt ?? ""),
        "user: " \(userMessage)
        """
    }

    private func encodeMistralPrompt() -> String {
        """
        <s>
        \(history.last?.mistralPrompt ?? "")
        </s>
        [INST] \(userMessage) [/INST]
        """
    }

    private func encodePhiPrompt() -> String {
        """
        \(systemPrompt)
        \(history.last?.phiPrompt ?? "")
        <|user|>
        \(userMessage)
        <|end|>
        <|assistant|>
        """
    }
}
