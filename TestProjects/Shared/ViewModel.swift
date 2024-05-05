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
    
    init() {
        let path = Bundle.main.path(forResource: "llama-2-7b.Q4_K_M", ofType: "gguf") ?? ""
        swiftLlama = (try? SwiftLlama(modelPath: path))!
    }

    func run(for prompt: String) {
        result = ""
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
