import Foundation
import llama
import Combine

public class SwiftLlama {
    private let model: LlamaModel
    private var sessionSupport = false {
        didSet {
            if !sessionSupport {
                session = nil
            }
        }
    }
    private var session: Session?
    private lazy var resultSubject: CurrentValueSubject<String, Error> = {
        .init("")
    }()

    public init(modelPath: String,
                 modelConfiguration: Configuration = .init()) throws {
        self.model = try LlamaModel(path: modelPath, configuration: modelConfiguration)
    }

    private func prepareSessionIfNeeded(sessionSupport: Bool, for prompt: Prompt) {
        self.sessionSupport = sessionSupport
        if sessionSupport {
            if session == nil {
                session = Session(prompt: prompt)
            } else {
                session?.prompt = prompt
            }
        }
    }

    @SwiftLlamaActor
    public func start(for prompt: Prompt, sessionSupport: Bool = false) -> AsyncThrowingStream<String, Error> {
        prepareSessionIfNeeded(sessionSupport: sessionSupport, for: prompt)
        return .init { continuation in
            Task {
                defer { model.clear() }
                do {
                    try model.start(for: session?.sessionPrompt ?? prompt)
                    while model.shouldContinue {
                        let delta = try model.continue()
                        continuation.yield(delta)
                        session?.response(delta: delta)
                    }
                    continuation.finish()
                    session?.endRespose()
                } catch {
                    continuation.finish(throwing: error)
                    session?.endRespose()
                }
            }
        }
    }

    @SwiftLlamaActor
    public func start(for prompt: Prompt, sessionSupport: Bool = false) -> AnyPublisher<String, Error> {
        prepareSessionIfNeeded(sessionSupport: sessionSupport, for: prompt)
        Task {
            defer { model.clear() }
            do {
                try model.start(for: prompt)
                while model.shouldContinue {
                    let delta = try model.continue()
                    resultSubject.send(delta)
                    session?.response(delta: delta)
                }
                resultSubject.send(completion: .finished)
                session?.endRespose()
            } catch {
                resultSubject.send(completion: .finished)
                session?.endRespose()
            }
        }
        return resultSubject.eraseToAnyPublisher()
    }
}
