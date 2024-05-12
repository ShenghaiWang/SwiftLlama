import Foundation

public enum StopToken {}

public extension StopToken {
    static var phi: [String] {
        [
            "<|end|>",
            "<|assistant|>",
            "<|user|>",
        ]
    }

    static var llama: [String] {
        [
            "[INST]",
        ]
    }

    static var llama3: [String] {
        [
            "<|start_header_id|>",
            "<|eot_id|>",
        ]
    }

    static var chatML: [String] {
        [
            "<|im_end|>"
        ]
    }
}
