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

class AsyncOperation: BaseOperation {
    typealias Action = (AsyncOperation) -> Void
    
    private let action: Action
    private let sync: Bool
    
    init(sync: Bool = false, action: @escaping Action) {
        self.sync = sync
        self.action = action
    }
    
    override final func execute() {
        if !isCancelled {
            action(self)
            
            if sync {
                finish()
            }
        }
    }
}
