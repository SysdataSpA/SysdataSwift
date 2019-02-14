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

public enum ContainerError: Error {
    case componentNotFound
    case cantCreateComponent
}

public protocol Container {
    
    typealias Factory<T> = (Container) throws -> T
    
    func register<T>(type: T.Type, instance: T)
    func register<T>(key: String, instance: T)
    func register<T>(type: T.Type, factory: @escaping Factory<T>)
    func register<T, S>(type: T.Type, instanceType: S.Type)
    
    func resolve<T>() throws -> T 
    func resolve<T>(key: String) throws -> T
    func resolveInstanceType<T, S>(type: T.Type) throws -> S.Type
}
