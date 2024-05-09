#  SwiftLlama

This is basically a wrapper of [llama.cpp](https://github.com/ggerganov/llama.cpp.git) package 
and the purpose of this repo is to provide a swiftier API for Swift developers.

## Install

    .package(url: "https://github.com/ShenghaiWang/SwiftLlama.git", from: "0.2.0")

## Usage

### 1 Initialise swiftLlama using model path.

    let swiftLlama = try SwiftLlama(modelPath: path))
    
### 2 Call it

### Call without streaming

    let response: String = try await swiftLlama.start(for: prompt)

#### Using AsyncStream for streaming

    for try await value in await swiftLlama.start(for: prompt) {
        result += value
    }

#### Using Combine publisher for streaming

    await swiftLlama.start(for: prompt)
        .sink { _ in

        } receiveValue: {[weak self] value in
            self?.result += value
        }.store(in: &cancallable)

## Test projects

[This video](https://youtu.be/w1VEM00cJWo) was the command line app running with Llama 3 model.

For using it in iOS or MacOS app, please refer to the [TestProjects](https://github.com/ShenghaiWang/SwiftLlama/tree/main/TestProjects) folder.


## Supported Models

In theory, it should support all the models that llama.cpp suports. However, the prompt format might need to be updated for some models.

If you want to test it out quickly, please use this model [codellama-7b-instruct.Q4_K_S.gguf](https://huggingface.co/TheBloke/CodeLlama-7B-Instruct-GGUF/resolve/main/codellama-7b-instruct.Q4_K_S.gguf?download=true)

## Welcome to contribute!!!



