import Foundation
import SwiftLlama

if CommandLine.arguments.count < 2 {
    print("Usage: swiftllama model_file_path")
    exit(1)
}

guard let modelPath = CommandLine.arguments.last else {
    exit(1)
}

guard let swiftLlama = try? SwiftLlama(modelPath: modelPath) else {
    print("Cannot load model.")
    exit(1)
}

while true {
    print("You:", terminator: " ")
    let userMessage = readLine() ?? ""
    print("Bot:", terminator: " ")

    for try await value in await swiftLlama
        .start(for: .init(type: .llama,
                          systemPrompt: "You are a helpful coding AI assistant.",
                          userMessage: userMessage)) {
        print(value, terminator: "")
    }
    print("")
}
