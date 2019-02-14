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

open class BaseOperation: Operation {
    
    // chiamo gli stati allo stesso modo per notificare il KVO
    public enum OperationState: String {
        case isReady
        case isExecuting
        case isFinished
        case isCancelled
    }
    
    private let stateLock = NSLock()
    
    private var rawState: OperationState = .isReady
    public private(set) var state: OperationState {
        get {
            return stateLock.scope { rawState }
        }
        set {
            // devo scatenare il KVO
            willChangeValue(forKey: "state")
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
            let oldValue: OperationState = stateLock.scope {
                let old = rawState
                rawState = newValue
                return old
            }
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
            didChangeValue(forKey: "state")
        }
    }
    
    // consentiamo a tutte di eseguire codice asincrono
    override open var isAsynchronous: Bool { return true }
    
    override open var isReady: Bool { return rawState == .isReady }
    override open var isExecuting: Bool { return rawState == .isExecuting }
    override open var isFinished: Bool { return rawState == .isFinished }
    override open var isCancelled: Bool { return rawState == .isCancelled }
    
    override open func start() {
        if isCancelled {
            state = .isFinished
        } else {
            state = .isReady
            main()
        }
    }
    
    override open func main() {
        state = .isExecuting
        execute()
        executeInternalQueue()
    }
    
    open func execute() {
        state = .isFinished
    }
    
    override open func cancel() {
        super.cancel()
        childOperations.forEach { $0.cancel() }
        internalQueue.cancelAllOperations()
        state = .isCancelled
    }
    
    public func finish() {
        state = .isFinished
    }
    
    // MARK: - Children
    lazy var childOperations: [Operation] = [Operation]()
    lazy var internalQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "\(self)"
        queue.isSuspended = true
        queue.qualityOfService = .default
        return queue
    }()

}

// bisogna rendere le cose thread safe
extension NSLock {
    func scope<T>(_ block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

extension BaseOperation {
    
    func add(child operation: Operation) {
        childOperations.append(operation)
    }
    
    func add(internal operation: Operation) {
        if isCancelled { return finish() }
        internalQueue.addOperation(operation)
    }
    
    internal func executeInternalQueue() {
        if isCancelled { return finish() }
        internalQueue.isSuspended = false
    }
}
