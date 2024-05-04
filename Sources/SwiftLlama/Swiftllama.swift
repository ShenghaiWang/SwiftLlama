import Foundation
import llama

public class SwiftLlama {
    private let model: LlamaModel

    public init(modelPath: String,
                 modelConfiguration: Configuration = .init()) throws {
        self.model = try LlamaModel(path: modelPath, configuration: modelConfiguration)
    }
    
    @SwiftllamaActor
    public func inference(for prompt: String) -> AsyncThrowingStream<String, Error> {
        .init { continuation in
            defer { model.clear() }
            do {
                try model.start(for: prompt)
                while model.shouldContinue {
                    let delta = try model.continue()
                    continuation.yield(delta ?? "")
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
