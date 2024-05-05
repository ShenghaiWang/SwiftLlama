import Foundation
import llama
import Combine

public class SwiftLlama {
    private let model: LlamaModel
    private lazy var resultSubject: CurrentValueSubject<String, Error> = {
        .init("")
    }()

    public init(modelPath: String,
                 modelConfiguration: Configuration = .init()) throws {
        self.model = try LlamaModel(path: modelPath, configuration: modelConfiguration)
    }

    @SwiftLlamaActor
    public func start(for prompt: String) -> AsyncThrowingStream<String, Error> {
        .init { continuation in
            Task {
                defer { model.clear() }
                do {
                    try model.start(for: prompt)
                    while model.shouldContinue {
                        let delta = try model.continue()
                        continuation.yield(delta)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    @SwiftLlamaActor
    public func start(for prompt: String) -> AnyPublisher<String, Error> {
        Task {
            defer { model.clear() }
            do {
                try model.start(for: prompt)
                while model.shouldContinue {
                    let delta = try model.continue()
                    resultSubject.send(delta)
                }
                resultSubject.send(completion: .finished)
            } catch {
                resultSubject.send(completion: .finished)
            }
        }
        return resultSubject.eraseToAnyPublisher()
    }
}
