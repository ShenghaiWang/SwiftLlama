import Foundation
import llama

public struct Configuration {
    public let seed: UInt32
    public let topK: Int32
    public let topP: Float
    public let nCTX: UInt32
    public let temperature: Float
    public let stopSequence: String?
    public let historyLimit: Int
    public let maxTokenCount: Int32

    public init(seed: UInt32 = 1234,
                topK: Int32 = 50,
                topP: Float = 0.9,
                nCTX: UInt32 = 2048,
                temperature: Float = 0.6,
                stopSequence: String? = nil,
                historyLimit: Int = 10,
                maxTokenCount: Int32 = 64) {
        self.seed = seed
        self.topK = topK
        self.topP = topP
        self.nCTX = nCTX
        self.temperature = temperature
        self.stopSequence = stopSequence
        self.historyLimit = historyLimit
        self.maxTokenCount = maxTokenCount
    }
}

extension Configuration {
    var contextParameters: ContextParameters {
        var params = llama_context_default_params()
        let processorCount = max(1, min(8, ProcessInfo.processInfo.processorCount - 2))
        params.seed = self.seed
        params.n_ctx = self.nCTX
        params.n_threads = UInt32(processorCount)
        params.n_threads_batch = UInt32(processorCount)
        return params
    }
}
