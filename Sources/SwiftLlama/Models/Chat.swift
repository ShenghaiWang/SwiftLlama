import Foundation

public struct Chat {
    public let user: String
    public let bot: String

    public init(user: String, bot: String) {
        self.user = user
        self.bot = bot
    }
}

extension Chat {
    var chatMLPrompt: String {
        """
        "<|im_start|>user
        \(user)<|im_end|>
        <|im_start|>assistant
        \(bot)<|im_end|>
        """
    }

    var llamaPrompt: String {
         """
         "[INST]"\(user)"[/INST]",
         "[INST]<<SYS>>"\(bot)"<</SYS>>[/INST]",
         """
    }

    var llama3Prompt: String {
        [
            user.isEmpty ? nil : "<|start_header_id|>user<|end_header_id|>\(user)<|eot_id|>",
            bot.isEmpty ? nil : "<|start_header_id|>assistant<|end_header_id|>\(bot)<|eot_id|>",
        ].compactMap{ $0 }.joined(separator: "\n")
    }

    var mistralPrompt: String {
        """
        "[INST]"\(user)"[/INST]"
        "[INST]"\(bot)"[/INST]"
        """
    }

    var phiPrompt: String {
        """
        <|user|>
        \(user)
        <|end|>
        <|assistant|>
        \(bot)
        """
    }

    var gemmaPrompt: String {
        """
        <start_of_turn>user
        \(user)
        <end_of_turn>
        <start_of_turn>model
        \(bot)
        <end_of_turn>
        """
    }

}
