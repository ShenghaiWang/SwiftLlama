import Foundation
import llama

public struct Configuration {
    static var historySize = 5
    public let seed: Int
    public let topK: Int
    public let topP: Float
    public let nCTX: Int
    public let temperature: Float
    public let maxTokenCount: Int
    public let batchSize: Int
    public let stopTokens: [String]

    public init(seed: Int = 1234,
                topK: Int = 40,
                topP: Float = 0.9,
                nCTX: Int = 2048,
                temperature: Float = 0.2,
                batchSize: Int = 2048,
                stopSequence: String? = nil,
                historySize: Int = 5,
                maxTokenCount: Int = 1024,
                stopTokens: [String] = []) {
        self.seed = seed
        self.topK = topK
        self.topP = topP
        self.nCTX = nCTX
        self.batchSize = batchSize
        self.temperature = temperature
        Self.historySize = historySize
        self.maxTokenCount = maxTokenCount
        self.stopTokens = stopTokens
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
