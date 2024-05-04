import Foundation
import SwiftLlama
import SwiftUI

@Observable
class ViewModel {
    let swiftLlama: SwiftLlama
    var result = ""

    init() {
        let path = Bundle.main.path(forResource: "llama-2-7b.Q4_K_M", ofType: "gguf") ?? ""
        swiftLlama = (try? SwiftLlama(modelPath: path))!
    }

    func run(for prompt: String) {
        Task {
            result = ""
            for try await value in await swiftLlama.inference(for: prompt) {
                result += value
            }
        }
    }
}
