import Foundation

public enum StopToken {}

public extension StopToken {
    static var phi: [String] {
        [
            "<|end|>",
        ]
    }

    static var llama: [String] {
        [
            "[/INST]",
        ]
    }

    static var llama3: [String] {
        [
            "<|eot_id|>",
        ]
    }

    static var chatML: [String] {
        [
            "<|im_end|>"
        ]
    }
}
