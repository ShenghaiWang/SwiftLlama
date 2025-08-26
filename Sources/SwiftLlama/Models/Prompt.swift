import Foundation

public struct Prompt {
    public enum `Type` {
        case chatML
        case alpaca
        case llama
        case llama3
        case mistral
        case phi
        case gemma
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
        case .gemma: encodeGemmaPrompt()
        }
    }

    private func encodeLlamaPrompt() -> String {
        """
        [INST]<<SYS>>
        \(systemPrompt)
        <</SYS>>
        \(history.suffix(Configuration.historySize).map { $0.llamaPrompt }.joined())
        [/INST]
        [INST]
        \(userMessage)
        [/INST]
        """
    }

    private func encodeLlama3Prompt() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        df.dateFormat = "d MMM yyyy"
        let today = df.string(from: Date())

        let systemBlock = """
        <|start_header_id|>system<|end_header_id|>

        Cutting Knowledge Date: December 2023
        Today Date: \(today)

        \(systemPrompt)<|eot_id|>
        """

        let historyBlock = history.suffix(Configuration.historySize)
            .map { $0.llama3Prompt }
            .joined(separator: "\n")

        let tail = """
        <|start_header_id|>user<|end_header_id|>
        \(userMessage)<|eot_id|>
        <|start_header_id|>assistant<|end_header_id|>
        """

        return [systemBlock, historyBlock, tail]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n\n")
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
        \(history.suffix(Configuration.historySize).map { $0.chatMLPrompt }.joined())
        "<|im_start|>user"
        \(userMessage)<|im_end|>
        <|im_start|>assistant
        """
    }

    private func encodeMistralPrompt() -> String {
        """
        <s>
        \(history.suffix(Configuration.historySize).map { $0.mistralPrompt }.joined())
        </s>
        [INST] \(userMessage) [/INST]
        """
    }

    private func encodePhiPrompt() -> String {
        """
        \(systemPrompt)
        \(history.suffix(Configuration.historySize).map { $0.phiPrompt }.joined())
        <|user|>
        \(userMessage)
        <|end|>
        <|assistant|>
        """
    }

    private func encodeGemmaPrompt() -> String {
        """
        <start_of_turn>system
        \(systemPrompt)
        <end_of_turn>
        \(history.suffix(Configuration.historySize).map { $0.gemmaPrompt }.joined())
        <start_of_turn>user
        \(userMessage)
        <end_of_turn>
        <start_of_turn>model
        """
    }
}
