import Foundation
import llama

class LlamaModel {
    private let model: Model
    private let configuration: Configuration
    private let context: OpaquePointer
    private var batch: Batch
    private var tokens: [Token]
    private var temporaryInvalidCChars: [CChar] = []
    private var generatedTokenAccount: Int32 = 0

    var shouldContinue: Bool {
        generatedTokenAccount < configuration.maxTokenCount
    }

    init?(path: String, configuration: Configuration = .init()) {
        self.configuration = configuration
        llama_backend_init()
        var model_params = llama_model_default_params()
        #if targetEnvironment(simulator)
        model_params.n_gpu_layers = 0
        #endif
        guard let model = llama_load_model_from_file(path, model_params) else {
            return nil
        }
        self.model = model
        guard let context = llama_new_context_with_model(model, configuration.contextParameters) else {
            return nil
        }
        self.context = context
        self.tokens = []
        self.batch = llama_batch_init(512, 0, 1)
    }

    func start(for prompt: String) throws {
        tokens = tokenize(text: prompt, addBos: true)
        temporaryInvalidCChars = []
        batch.clear()

        tokens.enumerated().forEach { index, token in
            batch.add(token: token, position: Int32(index), seqIDs: [0], logit: false)
        }
        batch.logits[Int(batch.n_tokens) - 1] = 1 // true

        if llama_decode(context, batch) != 0 {
            throw SwiftLlamaError.decodeError
        }
        generatedTokenAccount = batch.n_tokens
    }

    func `continue`() throws -> String {
        let n_vocab = llama_n_vocab(model)
        guard let logits = llama_get_logits_ith(context, batch.n_tokens - 1) else {
            return ""
        }

        let newToken: Token = {
            var candidates = Array<llama_token_data>(unsafeUninitializedCapacity: Int(n_vocab)) { buffer, initializedCount in
                for id in 0..<n_vocab {
                    let logit = logits[Int(id)]
                    buffer[Int(id)] = llama_token_data(id: id, logit: logit, p: 0.0)
                }
                initializedCount = Int(n_vocab)
            }

            var candidatesArray = llama_token_data_array(
                data: candidates.withUnsafeMutableBufferPointer { $0.baseAddress! },
                size: Int(n_vocab),
                sorted: false
            )

            return llama_sample_token_greedy(context, &candidatesArray)
        }()

        if llama_token_is_eog(model, newToken) || generatedTokenAccount == configuration.maxTokenCount {
            temporaryInvalidCChars.removeAll()
            return ""
        }

        let newTokenCChars = tokenToCChars(token: newToken)
        temporaryInvalidCChars.append(contentsOf: newTokenCChars)

        let newTokenStr: String
        if let validString = String(validatingUTF8: temporaryInvalidCChars + [0]) {
            newTokenStr = validString
            temporaryInvalidCChars.removeAll()
        } else if let suffixIndex = temporaryInvalidCChars.firstIndex(where: { $0 != 0 }),
                  let validSuffix = String(validatingUTF8: Array(temporaryInvalidCChars.suffix(from: suffixIndex)) + [0]) {
            newTokenStr = validSuffix
            temporaryInvalidCChars.removeAll()
        } else {
            newTokenStr = ""
        }

        batch.clear()
        batch.add(token: newToken, position: generatedTokenAccount, seqIDs: [0], logit: true)
        generatedTokenAccount += 1

        if llama_decode(context, batch) != 0 {
            throw SwiftLlamaError.decodeError
        }
        return newTokenStr
    }

    private func tokenToCChars(token: llama_token) -> [CChar] {
        var length: Int32 = 8
        var piece = Array<CChar>(repeating: 0, count: Int(length))

        let nTokens = llama_token_to_piece(model, token, &piece, length, false)
        if nTokens >= 0 {
            return Array(piece.prefix(Int(nTokens)))
        } else {
            length = -nTokens
            piece = Array<CChar>(repeating: 0, count: Int(length))
            let nNewTokens = llama_token_to_piece(model, token, &piece, length, false)
            return Array(piece.prefix(Int(nNewTokens)))
        }
    }

    private func tokenize(text: String, addBos: Bool) -> [Token] {
        let utf8Count = text.utf8.count
        let n_tokens = utf8Count + (addBos ? 1 : 0) + 1
        return Array(unsafeUninitializedCapacity: n_tokens) { buffer, initializedCount in
            initializedCount = Int(
                llama_tokenize(model, text, Int32(utf8Count), buffer.baseAddress, Int32(n_tokens), addBos, false)
            )
        }
    }

    func clear() {
        tokens.removeAll()
        temporaryInvalidCChars.removeAll()
        llama_kv_cache_clear(context)
    }

    deinit {
        llama_batch_free(batch)
        llama_free(context)
        llama_free_model(model)
        llama_backend_free()
    }
}
