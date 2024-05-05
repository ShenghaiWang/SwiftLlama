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
        {
            "role": "user",
            "content": \(user),
        },
        {
            "role": "system",
            "content": \(bot)
        }
        """
    }

    var mistralPrompt: String {
        """
        "[INST]" \(user) "[/INST]"
        "[INST]" \(bot) "[/INST]"
        """
    }

}
