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

public protocol Coordinator {
    var navigationController: UINavigationController? { get }
    var rootViewController: UIViewController? { get }
    var coordinatorContainer: Container { get }
    
    init(coordinatorContainer: Container)
    
    func start<PRM>(context: Context<PRM>)
    func start<PRM>(context: Context<PRM>, rootViewController: UIViewController?)
    func performAction<A, PRM>(action actionKey: A, context: Context<PRM>)
}
