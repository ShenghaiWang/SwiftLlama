#  SwiftLlama

This is basically a wrapper of [llama.cpp](https://github.com/ggerganov/llama.cpp.git) package 
and the purpose of this repo is to provide a swiftier api.

## Install

    .package(url: "https://github.com/ShenghaiWang/SwiftLlama.git", from: "0.1.0")

## Usage

### 1 Initialise swiftLlama using model path.

    let swiftLlama = try SwiftLlama(modelPath: path))
    
### 2 Call it 

#### Using AsyncStream method

    for try await value in await swiftLlama.start(for: prompt) {
        result += value
    }

#### Using Combine publisher

    await swiftLlama.start(for: prompt)
        .sink { _ in

        } receiveValue: {[weak self] value in
            self?.result += value
        }.store(in: &cancallable)

## Test projects

Please refer to the TestProjects folder for usage. 

[This video](https://youtu.be/w1VEM00cJWo) was the command line app running with Llama 3 model.

For using it in iOS or MacOS app, please refer to the [TestProjects folder](https://github.com/ShenghaiWang/SwiftLlama/tree/main/TestProjects) 

## Welcome to contribute!!!



