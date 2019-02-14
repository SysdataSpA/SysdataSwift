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

public protocol Contextable {
    var coordinator: Coordinator { get set }
    var core: Container { get set }
}

public struct Context<P>: Contextable {
    public let param: P
    public var coordinator: Coordinator
    public var core: Container
    
    public init(param: P, coordinator: Coordinator, core: Container) {
        self.param = param
        self.coordinator = coordinator
        self.core = core
    }
}

public extension Context {
    func make<Param>(param: Param) -> Context<Param> {
        return Context<Param>(param: param, coordinator: coordinator, core: core)
    }
    func make() -> Context<Void> {
        return Context<Void>(param: Void(), coordinator: coordinator, core: core)
    }
    func make(coordinator: Coordinator) -> Context<P> {
        return Context<P>(param: param, coordinator: coordinator, core: core)
    }
}

public extension Context where P == Void {
    init(coordinator: Coordinator, core: Container) {
        self.init(param: Void(), coordinator: coordinator, core: core)
    }
}
