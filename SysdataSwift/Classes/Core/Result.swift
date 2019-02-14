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

public typealias Completion<T, E: Error> = (Result<T, E>) -> Void

public enum Result<T, E: Error> {
    case success(T)
    case failure(E)
    
    var value: T? {
        switch self {
        case .success(let res):
            return res
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .failure(let err):
            return err
        default:
            return nil
        }
    }
}
