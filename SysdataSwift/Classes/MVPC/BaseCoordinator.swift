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
import UIKit

public enum NavigationType {
    case push(animated: Bool)
    case pushFirst(animated: Bool)
    case modal(animated: Bool)
    case custom(block: (_ vc: UIViewController) -> Void)
}

public protocol CoordinatorEnums {
    associatedtype ACT
    associatedtype NOD: RawRepresentable
}

open class BaseCoordinator<E: CoordinatorEnums> {
    
    public private(set) var navigationController: UINavigationController?
    public private(set) var rootViewController: UIViewController?

    public let coordinatorContainer: Container
    private let nodeContainer: Container = BaseContainer()
    private let updateSuffixKey = "_update_context"
    
    /// Espone la lista dei nodi gestite dal coordinator
    public var nodes: E.NOD.Type {
        return E.NOD.self
    }
    
    /// Espone la lista delle azioni gestite dal coordinator
    public var actions: E.ACT.Type {
        return E.ACT.self
    }
    
    required public init(coordinatorContainer: Container) {
        self.coordinatorContainer = coordinatorContainer
        
        registerAllNodes()
    }
    
    open func registerAllNodes() {}
    
    // MARK: Start
    
    open func start<PRM>(context: Context<PRM>) {
        start(context: context, rootViewController: nil)
    }
    
    open func start<PRM>(context: Context<PRM>, rootViewController: UIViewController? = nil) {
        self.rootViewController = rootViewController
        self.navigationController = rootViewController as? UINavigationController
    }
    
    // MARK: Registration
    
    public func registerNode<V: Presentable, P: Presenter>(keyString: String, view: V.Type, presenter: P.Type) where P.View == V, P.Act == E.ACT {
        
        let block: (_ context: P.Ctx) -> UIViewController? = { ctx in
            guard let presenter = presenter.init(context: ctx) as? BasePresenter<V, P.Ctx, E.ACT> else {
                assertionFailure("Presenter not valid for node with key: \(keyString)")
                return nil
            }
            
            return presenter.start() as? UIViewController
        }
        nodeContainer.register(key: keyString, instance: block)
        
        let blockUpdate: (_ vc: UIViewController, _ context: P.Ctx) -> Void = { vc, ctx in
            guard let presentableVc = vc as? V,
                let presenterP = presentableVc.presenter as? P else {
                assertionFailure("ViewController not valid for node with key: \(keyString)")
                return
            }
            
            presenterP.context = ctx
        }
        nodeContainer.register(key: "\(keyString)\(updateSuffixKey)", instance: blockUpdate)
    }
    
    public func registerNode<V: Presentable, P: Presenter>(key: E.NOD, view: V.Type, presenter: P.Type) where P.View == V, P.Act == E.ACT {
        let keyString = String(describing: key.rawValue)
        return registerNode(keyString: keyString, view: view, presenter: presenter)
    }
    
    // MARK: Build
    
    public func buildNode<PRM>(key: String, context: Context<PRM>) -> UIViewController? {
        var currentContext = context
        if type(of:context.coordinator) != type(of: self) {
            currentContext = context.make(coordinator: self)
        }
        guard let node: (_ context: Context<PRM>) -> UIViewController? = try? nodeContainer.resolve(key: key) else {
            assertionFailure("Unregistered node with key: \(key)")
            return nil
        }
        
        return node(currentContext)
    }
    
    public func buildNode<PRM>(key: E.NOD, context: Context<PRM>) -> UIViewController?  {
        let keyString = String(describing: key.rawValue)
        return buildNode(key: keyString, context: context)
    }
    
    public func updateContext<PRM>(key: E.NOD, vc: UIViewController, context: Context<PRM>) {
        let keyString = String(describing: key.rawValue)
        updateContext(key: keyString, vc: vc, context: context)
    }
    
    public func updateContext<PRM>(key: String, vc: UIViewController, context: Context<PRM>) {
        var currentContext = context
        if type(of:context.coordinator) != type(of: self) {
            currentContext = context.make(coordinator: self)
        }
        guard let update: (_ vc: UIViewController, _ context: Context<PRM>) -> Void = try? nodeContainer.resolve(key: "\(key)\(updateSuffixKey)") else {
            assertionFailure("Unregistered node with key: \(key)")
            return
        }
        
        return update(vc, currentContext)
    }
    
    // MARK: Action
    
    open func actionManagement<PRM>(action actionKey: E.ACT, context: Context<PRM>) {
        assertionFailure("Implement method performAction in your specific coordinator")
    }
}

// MARK: Navigation
 extension BaseCoordinator {
    open func navigate<PRM>(withVc vc: UIViewController, context: Context<PRM>, navigation: NavigationType = .push(animated: true)) {
        switch navigation {
        case .push(let animated):
            self.navigationController?.pushViewController(vc, animated: animated)
        case .pushFirst(let animated) :
            self.navigationController?.setViewControllers([vc], animated: animated)
        case .modal(let animated):
            self.navigationController?.finalPresentedViewController.present(vc, animated: animated, completion: nil)
        case .custom(let block):
            block(vc)
        }
    }
    
    open func navigate<PRM>(toNode key: E.NOD, context: Context<PRM>, navigation: NavigationType = .push(animated: true)) {
        guard let vc = buildNode(key: key, context: context) else {
            assertionFailure("Coordinator can't navigate to node with given key: \(key)")
            return
        }
        
        self.navigate(withVc: vc, context: context, navigation: navigation)
    }
}

extension BaseCoordinator: Coordinator {
    // MARK: Action
    
    open func performAction<A, PRM>(action actionKey: A, context: Context<PRM>) {
        guard let key = actionKey as? E.ACT else {
            assertionFailure("Action with key \"\(actionKey)\" not valid for current coordinator")
            return
        }
        
        actionManagement(action: key, context: context)
    }
}
