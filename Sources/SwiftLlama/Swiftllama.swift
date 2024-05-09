import Foundation
import llama
import Combine

public class SwiftLlama {
    private let model: LlamaModel
    private var contentStarted = false
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

    private func prepare(sessionSupport: Bool, for prompt: Prompt) {
        contentStarted = false
        self.sessionSupport = sessionSupport
        if sessionSupport {
            if session == nil {
                session = Session(prompt: prompt)
            } else {
                session?.prompt = prompt
            }
        }
    }

    private func response(for prompt: Prompt, output: (String) -> Void, finish: () -> Void) {
        defer { model.clear() }
        do {
            try model.start(for: prompt)
            while model.shouldContinue {
                var delta = try model.continue()
                if contentStarted { // remove the prefix empty spaces
                    output(delta)
                } else {
                    delta = delta.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !delta.isEmpty {
                        contentStarted = true
                        output(delta)
                    }
                }
            }
            finish()
        } catch {
            finish()
        }
    }

    @SwiftLlamaActor
    public func start(for prompt: Prompt, sessionSupport: Bool = false) -> AsyncThrowingStream<String, Error> {
        prepare(sessionSupport: sessionSupport, for: prompt)
        return .init { continuation in
            Task {
                response(for: prompt) { [weak self] delta in
                    continuation.yield(delta)
                    self?.session?.response(delta: delta)
                } finish: { [weak self] in
                    continuation.finish()
                    self?.session?.endRespose()
                }
            }
        }
    }

    @SwiftLlamaActor
    public func start(for prompt: Prompt, sessionSupport: Bool = false) -> AnyPublisher<String, Error> {
        prepare(sessionSupport: sessionSupport, for: prompt)
        Task {
            response(for: prompt) { delta in
                resultSubject.send(delta)
                session?.response(delta: delta)
            } finish: {
                resultSubject.send(completion: .finished)
                session?.endRespose()
            }
        }
        return resultSubject.eraseToAnyPublisher()
    }
}
