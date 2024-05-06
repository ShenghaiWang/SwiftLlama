import Foundation
import llama

public struct Configuration {
    public let seed: Int
    public let topK: Int
    public let topP: Float
    public let nCTX: Int
    public let temperature: Float
    public let stopSequence: String?
    public let historyLimit: Int
    public let maxTokenCount: Int
    public let batchSize: Int

    public init(seed: Int = 1234,
                topK: Int = 40,
                topP: Float = 0.9,
                nCTX: Int = 2048,
                temperature: Float = 0.2,
                batchSize: Int = 4096,
                stopSequence: String? = nil,
                historyLimit: Int = 10,
                maxTokenCount: Int = 1024) {
        self.seed = seed
        self.topK = topK
        self.topP = topP
        self.nCTX = nCTX
        self.batchSize = batchSize
        self.temperature = temperature
        self.stopSequence = stopSequence
        self.historyLimit = historyLimit
        self.maxTokenCount = maxTokenCount
    }
}

extension Configuration {
    var contextParameters: ContextParameters {
        var params = llama_context_default_params()
        let processorCount = max(1, min(16, ProcessInfo.processInfo.processorCount - 2))
        params.seed = UInt32(self.seed)
        params.n_ctx = max(8, UInt32(self.nCTX)) // minimum context size is 8
        params.n_threads = UInt32(processorCount)
        params.n_threads_batch = UInt32(processorCount)
        return params
    }
}
