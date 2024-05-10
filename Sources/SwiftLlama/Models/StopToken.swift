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
}
