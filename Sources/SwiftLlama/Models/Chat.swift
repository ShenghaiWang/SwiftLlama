import Foundation

public struct Chat {
    let user: String
    let bot: String
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
         """
         <|start_header_id|>user<|end_header_id|>\(user)<|eot_id|>
         <|start_header_id|>assistant<|end_header_id|>\(bot)<|eot_id|>
         """
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

}
