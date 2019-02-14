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

public extension UIViewController {
    
    /**
     It returns the topmost presented viewcontroller
     */
    public var finalPresentedViewController: UIViewController {
        if let presentedVC = presentedViewController {
            return presentedVC.finalPresentedViewController
        }
        return self
    }
    
    /**
     It returns the topmost viewcontroller
     */
    public var finalViewController: UIViewController {
        if let navigationController = self as? UINavigationController, let visibleVC = navigationController.visibleViewController {
            return visibleVC.finalViewController
        }
        if let tabBarController = self as? UITabBarController, let selectedVC = tabBarController.selectedViewController {
            return selectedVC.finalViewController
        }
        return self
    }
    
    /**
     It tells if self is modally presented
     */
    public var isPresentedModally: Bool {
        return self.presentingViewController != nil
    }
}
