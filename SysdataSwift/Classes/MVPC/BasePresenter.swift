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

open class BasePresenter<V: Presentable, Ctx: Contextable, Act>: Presenter {
    public weak var view: V!
    public var context: Ctx!
    
    public var actions: Act.Type! {
        return Act.self
    }
    
    // serve rendere public l'inizializzatore che di default è internal
    public required init(context: Ctx) {
        self.context = context
    }
}
