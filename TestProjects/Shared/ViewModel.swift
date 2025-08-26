import Foundation
import SwiftLlama
import SwiftUI
import Combine

@Observable
class ViewModel {
    let swiftLlama: SwiftLlama
    var result = ""
    var usingStream = true
    private var cancallable: Set<AnyCancellable> = []
    
    struct LLamaModel {
        let modelName: String
        let type: Prompt.`Type`
        let stopTokens: [String]
    }
    
    static let llama2model: LLamaModel = .init(
        modelName: "llama-2-7b.Q4_K_M",
        type: .llama,
        stopTokens: StopToken.llama
    )
    
    static let llama3model: LLamaModel = .init(
        modelName: "Llama-3.2-3B-Instruct-Q4_K_L",
        type: .llama3,
        stopTokens: StopToken.llama3
    )
    
    let currentModel = llama3model
    
    init() {
        let path = Bundle.main.path(forResource: currentModel.modelName, ofType: "gguf") ?? ""
        swiftLlama = (try? SwiftLlama(
            modelPath: path,
            modelConfiguration: .init(stopTokens: currentModel.stopTokens))
        )!
    }
    
    func run(for userMessage: String) {
        result = ""
        
        let prompt = Prompt(type: currentModel.type,
                            systemPrompt: "You are a helpful coding AI assistant.",
                            userMessage: userMessage)
        Task {
            switch usingStream {
            case true:
                for try await value in await swiftLlama.start(for: prompt) {
                    result += value
                }
            case false:
                await swiftLlama.start(for: prompt)
                    .sink { _ in
                        
                    } receiveValue: {[weak self] value in
                        self?.result += value
                    }.store(in: &cancallable)
            }
        }
    }
}
