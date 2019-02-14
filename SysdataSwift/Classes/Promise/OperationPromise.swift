//
// Copyright 2019 Sysdata S.p.A.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public protocol OperationTicket {
    var identifier: String? { get }
    func cancel()
}

public protocol Chainable: AnyObject {
    associatedtype In
    associatedtype Out
    associatedtype Err: Throwable
    
    var onCompletion: Completion<Out, Err>? { get set }
    
    init(input: In, container: Container)
}

public final class OperationPromise<O: Chainable>: OperationTicket {
    public var identifier: String?
    
    typealias Callback = (Result<O.Out, O.Err>) -> Void
    
    private let type: O.Type
    
    private let container: Container
    private let queue: OperationQueue
    private var callbacks = [Callback]()
    
    private var onError: ((O.Err) -> Void)?
    private var onSuccess: ((O.Out) -> Void)?
    private var onCatchAll: ((Swift.Error) -> Void)?
    
    private var result: Result<O.Out, O.Err>?
    private var previousError: Swift.Error?
    
    public init(type: O.Type, container: Container, queue: OperationQueue) {
        self.type = type
        self.queue = queue
        self.container = container
    }
    
    deinit {
        print("OperationPromise deinit")
    }
    
    private func handlerError(_ error: Swift.Error?) {
        guard let localError = error else { return }
        onCatchAll?(localError)
        callbacks.forEach { callback in
            let callbackError = O.Err.map(error: localError)
            callback(.failure(callbackError))
        }
    }
    
    private func handleResult() {
        guard let operationResult = result else { return }
        self.callbacks.forEach { $0(operationResult) }
        
        switch operationResult {
        case let .success(value):
            onSuccess?(value)
        case let .failure(error):
            onError?(error)
            onCatchAll?(error)
        }
    }
    
    public func cancel() {
        queue.cancelAllOperations()
    }
}

// MARK: - Chaining functions
extension OperationPromise {
    @discardableResult
    public func start(input: O.In) -> O {
        let op = O(input: input, container: container)
        
        op.onCompletion = { [weak self] (result: Result<O.Out, O.Err>) in
            self?.result = result
            self?.handleResult()
        }
        
        if let operation = op as? Operation {
            queue.addOperation(operation)
        }
        
        return op
    }
    
    @discardableResult
    public func then<T: Chainable>(_ thenType: T.Type) -> OperationPromise<T> where T.In == O.Out {
        let promise = OperationPromise<T>(type: thenType, container: container, queue: queue)
        
        let callback: Callback = { (result: Result<O.Out, O.Err>) in
            if let output = result.value {
                promise.start(input: output)
            }
            
            if let error = result.error {
                promise.previousError = error
                promise.handlerError(error)
            }
        }
        
        callbacks.append(callback)
        
        if let operationResult = result {
            callback(operationResult)
        }
        
        return promise
    }
    
    @discardableResult
    public func then<Out>(_ block: @escaping (O.Out) throws -> Out) -> OperationPromise<ActionOperation<O.Out, Out>> {
        let promise = OperationPromise<ActionOperation<O.Out, Out>>(type: ActionOperation<O.Out, Out>.self, container: container, queue: queue)
        
        let callback: Callback = { (result: Result<O.Out, O.Err>) in
            if let output = result.value {
                promise.start(input: Action(input: output, action: block))
            }
            
            if let error = result.error {
                promise.previousError = error
                promise.handlerError(error)
            }
        }
        
        callbacks.append(callback)
        
        if let operationResult = result {
            callback(operationResult)
        }
        
        return promise
    }
    
    @discardableResult
    public func thenOnError<T: Chainable>(_ thenType: T.Type) -> OperationPromise<T> where T.In == O.Err {
        let promise = OperationPromise<T>(type: thenType, container: container, queue: queue)
        let callback: Callback = { (result: Result<O.Out, O.Err>) in
            guard let error = result.error as? O.Err else { return }
            promise.start(input: error)
        }
        
        callbacks.append(callback)
        
        if let operationResult = result {
            callback(operationResult)
        }
        
        return promise
    }
}

// MARK: - Handlers
extension OperationPromise {
    @discardableResult
    func success(_ body: @escaping (O.Out) -> Void) -> Self {
        onSuccess = body
        return self
    }
    
    @discardableResult
    func error(_ body: @escaping (O.Err) -> Void) -> Self {
        onError = body
        handlerError(previousError)
        return self
    }
    
    @discardableResult
    func catchAll(_ body: @escaping (Swift.Error) -> Void) -> Self {
        onCatchAll = body
        handlerError(previousError)
        return self
    }
}

public struct Action<In, Out> {
    public let input: In
    public let action: (In) throws -> Out
    
    public init(input: In, action: @escaping (In) throws -> Out) {
        self.input = input
        self.action = action
    }
}

public final class ActionError: Throwable {
    public static func map(error: Error) -> ActionError {
        return ActionError()
    }
}

public final class ActionOperation<I, O>: CompletionOperation<Action<I, O>, O, ActionError> {
    override public func executeThrows() throws {
        let output = try input.action(input.input)
        finish(output: output)
    }
}


public func firstly<T: Chainable>(with type: T.Type, input: T.In, container: Container, queue: OperationQueue? = nil) -> OperationPromise<T> {
    var chainQueue: OperationQueue
    if let queue = queue {
        chainQueue = queue
    } else {
        chainQueue = OperationQueue()
        chainQueue.name = "\(String(describing: type))"
        chainQueue.qualityOfService = .default
    }
    
    let operationPromise = OperationPromise<T>(type: type, container: container, queue: chainQueue)
    operationPromise.start(input: input)
    
    return operationPromise
}

public func firstly<In, Out>(block: @escaping (In) throws -> Out, input: In, container: Container, queue: OperationQueue? = nil) -> OperationPromise<ActionOperation<In, Out>> {
    var chainQueue: OperationQueue
    if let queue = queue {
        chainQueue = queue
    } else {
        chainQueue = OperationQueue()
        chainQueue.qualityOfService = .default
    }
    
    let operationPromise = OperationPromise<ActionOperation<In, Out>>(type: ActionOperation<In, Out>.self, container: container, queue: chainQueue)
    operationPromise.start(input: Action(input: input, action: block))
    return operationPromise
}
