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

open class BaseContainer {
    var components: [String: Any] = [:]
    
    public var lazyLoadingFactoryEnabled: Bool
    
    public init(lazyLoadingFactoryEnabled: Bool = false) {
        self.lazyLoadingFactoryEnabled = lazyLoadingFactoryEnabled
    }
}

private extension BaseContainer {
    func internalResolve<T>(key: String) throws -> T {
        guard let component = components[key] else {
            throw ContainerError.componentNotFound
        }
        
        if let factory = component as?  Factory<T> {
            let result = try factory(self)
            if lazyLoadingFactoryEnabled {
                register(key: key, instance: result)
            }
            return result
        }
        
        guard let result = component as? T else {
            throw ContainerError.cantCreateComponent
        }
        
        return result
    }
}

extension BaseContainer: Container {
    
    public func register<T>(type: T.Type, instance: T) {
        components["\(type)"] = instance
    }
    
    public func register<T>(key: String, instance: T) {
        components[key] = instance
    }
    
    public func register<T, S>(type: T.Type, instanceType: S.Type) {
        components["\(type)"] = instanceType
    }
    
    public func register<T>(type: T.Type, factory: @escaping Factory<T>) {
        components["\(type)"] = factory
    }
    
    public func resolve<T>() throws -> T {
        return try internalResolve(key: "\(T.self)")
    }
    
    public func resolve<T>(key: String) throws -> T {
        let result: T = try internalResolve(key: key)
        return result
    }
    
    public func resolveInstanceType<T, S>(type: T.Type) throws -> S.Type {
        let result: S.Type = try internalResolve(key: "\(T.self)")
        return result
    }
}
