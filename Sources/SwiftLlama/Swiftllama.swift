import Foundation
import llama
import Combine

public class SwiftLlama {
    private let model: LlamaModel
    private let configuration: Configuration
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
    private var generatedTokenCache = ""

    var maxLengthOfStopToken: Int {
        configuration.stopTokens.map { $0.count }.max() ?? 0
    }

    public init(modelPath: String,
                 modelConfiguration: Configuration = .init()) throws {
        self.model = try LlamaModel(path: modelPath, configuration: modelConfiguration)
        self.configuration = modelConfiguration
    }

    private func prepare(sessionSupport: Bool, for prompt: Prompt) -> Prompt {
        contentStarted = false
        generatedTokenCache = ""
        self.sessionSupport = sessionSupport
        if sessionSupport {
            if session == nil {
                session = Session(lastPrompt: prompt)
            } else {
                session?.lastPrompt = prompt
            }
            return session?.sessionPrompt ?? prompt
        } else {
            return prompt
        }
    }

    private func isStopToken() -> Bool {
        configuration.stopTokens.reduce(false) { partialResult, stopToken in
            generatedTokenCache.hasSuffix(stopToken)
        }
    }

    private func response(for prompt: Prompt, output: (String) -> Void, finish: () -> Void) {
        func finaliseOutput() {
            configuration.stopTokens.forEach {
                generatedTokenCache = generatedTokenCache.replacingOccurrences(of: $0, with: "")
            }
            output(generatedTokenCache)
            finish()
            generatedTokenCache = ""
        }
        defer { model.clear() }
        do {
            try model.start(for: prompt)
            while model.shouldContinue {
                var delta = try model.continue()
                if contentStarted { // remove the prefix empty spaces
                    if needToStop(after: delta, output: output) {
                        finish()
                        break
                    }
                } else {
                    delta = delta.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !delta.isEmpty {
                        contentStarted = true
                        if needToStop(after: delta, output: output) {
                            finish()
                            break
                        }
                    }
                }
            }
            finaliseOutput()
        } catch {
            finaliseOutput()
        }
    }

    /// Handling logic of StopToken
    private func needToStop(after delta: String, output: (String) -> Void) -> Bool {
        // If no stop tokens, just stream through
        guard maxLengthOfStopToken > 0 else {
            output(delta)
            return false
        }

        generatedTokenCache += delta

        // 1) If any stop token appears, cut output before it and stop
        if let stopRange = configuration.stopTokens
            .compactMap({ generatedTokenCache.range(of: $0) })
            .min(by: { $0.lowerBound < $1.lowerBound }) // earliest occurrence
        {
            let before = String(generatedTokenCache[..<stopRange.lowerBound])
            if !before.isEmpty { output(before) }
            generatedTokenCache.removeAll(keepingCapacity: false)
            return true
        }

        // 2) Stream everything except a small tail so split stop tokens are caught next time
        let tail = max(maxLengthOfStopToken - 1, 0)
        if generatedTokenCache.count > tail {
            let cut = generatedTokenCache.index(generatedTokenCache.endIndex, offsetBy: -tail)
            let safe = String(generatedTokenCache[..<cut])
            if !safe.isEmpty { output(safe) }
            generatedTokenCache.removeFirst(safe.count)
        }

        return false
    }

    @SwiftLlamaActor
    public func start(for prompt: Prompt, sessionSupport: Bool = false) -> AsyncThrowingStream<String, Error> {
        let sessionPrompt = prepare(sessionSupport: sessionSupport, for: prompt)
        return .init { continuation in
            Task {
                response(for: sessionPrompt) { [weak self] delta in
                    continuation.yield(delta)
                    self?.session?.response(delta: delta)
                } finish: { [weak self] in
                    continuation.finish()
                    self?.session?.endResponse()
                }
            }
        }
    }

    @SwiftLlamaActor
    public func start(for prompt: Prompt, sessionSupport: Bool = false) -> AnyPublisher<String, Error> {
        let sessionPrompt = prepare(sessionSupport: sessionSupport, for: prompt)
        Task {
            response(for: sessionPrompt) { delta in
                resultSubject.send(delta)
                session?.response(delta: delta)
            } finish: {
                resultSubject.send(completion: .finished)
                session?.endResponse()
            }
        }
        return resultSubject.eraseToAnyPublisher()
    }

    @SwiftLlamaActor
    public func start(for prompt: Prompt, sessionSupport: Bool = false) async throws -> String {
        var result = ""
        for try await value in start(for: prompt) {
            result += value
        }
        return result
    }
}
