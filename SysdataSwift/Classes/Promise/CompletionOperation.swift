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

public protocol Throwable: Error {
    static func map(error: Error) -> Self
}

open class CompletionOperation<Input, Output, E: Throwable>: BaseOperation, Chainable {
    
    var promise: AnyObject?
    public var onCompletion: Completion<Output, E>?
    
    public let input: Input
    public let container: Container
    
    public required init(input: Input, container: Container) {
        self.input = input
        self.container = container
    }
    
    public final func on(completion callback: @escaping Completion<Output, E>) {
        onCompletion = callback
    }
    
    public func finish(output: Output) {
        super.finish()
        onCompletion?(.success(output))
    }
    
    public func finish(error: E) {
        super.finish()
        onCompletion?(.failure(error))
    }
    
    @available(*, unavailable)
    override public func finish() {
        fatalError("devi usare gli altri finish")
    }
    
    open func executeThrows() throws {}
    
    override open func execute() {
        do {
            try executeThrows()
        } catch {
            finish(error: E.map(error: error))
        }
    }
}

extension CompletionOperation {
    @discardableResult
    func begin<T>(with type: T.Type, input: T.In) -> OperationPromise<T> {
        let operationPromise = OperationPromise<T>(type: type, container: container, queue: internalQueue)
        promise = operationPromise
        operationPromise.start(input: input)
        return operationPromise
    }
}

extension CompletionOperation where Input == Void {
    convenience init(container: Container) {
        self.init(input: Void(), container: container)
    }
}

public protocol Executable {
    var queue: OperationQueue { get }
    
    func execute<I, O, E: Error>(op: CompletionOperation<I, O, E>, completion: @escaping Completion<O, E>) -> Operation
}

public extension Executable {
    func execute<I, O, E: Error>(op: CompletionOperation<I, O, E>, completion: @escaping Completion<O, E>) -> Operation {
        op.on(completion: completion)
        queue.addOperation(op)
        return op
    }
}

extension OperationQueue: Executable {
    public var queue: OperationQueue {
        return self
    }
    
    public func execute<I, O, E: Error>(op: CompletionOperation<I, O, E>, completion: @escaping Completion<O, E>) -> Operation {
        op.on(completion: completion)
        addOperation(op)
        return op
    }
}
