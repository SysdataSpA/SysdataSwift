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

public protocol Presenter: AnyObject {
    associatedtype View
    associatedtype Ctx: Contextable
    associatedtype Act
    
    var view: View! { get set }
    var context: Ctx! { get set }
    var actions: Act.Type! { get }
    
    func start() -> View
    
    init(context: Ctx)
}

public extension Presenter where View: Presentable {
    func start() -> View {
        guard let presenter = self as? View.PRS else {
            fatalError("give a delegate")
        }
        
        let rootView = View(presenter: presenter)
        view = rootView
        return rootView
    }
}
