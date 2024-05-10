import Foundation

public struct Chat {
    let user: String
    let bot: String
}

extension Chat {
    var chatMLPrompt: String {
        """
        "user:" \(user)
        "bot:" \(bot)
        """
    }

    var llamaPrompt: String {
         """
         "[INST]" \(user) "[/INST]"
         "[INST]" \(bot) "[/INST]"
         """
    }

    var mistralPrompt: String {
        """
        "[INST]" \(user) "[/INST]"
        "[INST]" \(bot) "[/INST]"
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

}
