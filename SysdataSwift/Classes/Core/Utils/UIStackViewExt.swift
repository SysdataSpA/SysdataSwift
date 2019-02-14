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

extension UIStackView {
    
    /**
     It completely removes all arranged subviews from the views hierarchy
     */
    public func destroyAllArrangedSubviews() {
        for view in self.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
    
    /**
     It removes all arranged subviews without removing them from the views hierarchy
     */
    public func removeAllArrangedSubviews() {
        for view in self.arrangedSubviews {
            self.removeArrangedSubview(view)
        }
    }
    
    /**
     It inserts subview at the last position, animated if specified 
     
     - Parameter subview: the view to insert
     - Parameter animated: sliding animation if true, default false
     */
    public func addArrangedSubview(_ subview: UIView, animated: Bool = false) {
        self.insertArrangedSubview(subview, at: self.arrangedSubviews.count, animated: animated)
    }
    
    /**
     It insert subview at the given index, animated if specified 
     
     - Parameter subview: the view to insert
     - Parameter at: the index
     - Parameter animated: sliding animation if true, default false
     */
    public func insertArrangedSubview(_ subview: UIView, at index: Int, animated: Bool = false) {
        subview.layoutIfNeeded() // per evitare che il frame della vista abbia uno strano comportamento durante l'animazione
        if animated {
            subview.alpha = 0
            self.insertArrangedSubview(subview, at: index)
            
            UIView.animate(withDuration: 0.2, animations: { 
                self.topMostSuperView.layoutIfNeeded()
            }, completion: { (_: Bool) in
                UIView.animate(withDuration: 0.2) {
                    subview.alpha = 1
                }
            })
        } else {
            self.insertArrangedSubview(subview, at: index)
            self.topMostSuperView.layoutIfNeeded()
        }
    }
    
    /**
     If subview is a view in the arrangedSubviews array, it will insert the view after it 
     
     - Parameter view: the view to insert
     - Parameter after: the arranged subview after which inserting view
     - Parameter animated: sliding animation if true, default false
     */
    public func insertArrangedSubView(_ view: UIView, after subview: UIView, animated: Bool = false) {
        if let index = indexOf(subview: subview) {
            self.insertArrangedSubview(view, at: index + 1, animated: animated)
        }
    }
    
    /**
     If subview is a view in the arrangedSubviews array, it will insert the view before it 
     
     - Parameter view: the view to insert
     - Parameter before: the arranged subview before which inserting view
     - Parameter animated: sliding animation if true, default false
     */
    public func insertArrangedSubView(_ view: UIView, before subview: UIView, animated: Bool = false) {
        if let index = indexOf(subview: subview) {
            self.insertArrangedSubview(view, at: index, animated: animated)
        }
    }
    
    /**
     If arrangedSubview is a view in the arrangedSubviews array, it will return its index; nil otherwise
     
     - Parameter subview: the arranged subview to search
     - Returns: the index of the arranged subview if present, nil otherwise
     */
    public func indexOf(subview: UIView) -> Int? {
        for (index, view) in self.arrangedSubviews.enumerated() where view === subview {
            return index
        }
        return nil
    }
    
    /**
     It will remove the view at the given index if present 
     
     - Parameter index: the index
     - Parameter animated: sliding animation if true, default false
     */
    public func removeSubview(at index: Int, animated: Bool = false) {
        guard self.arrangedSubviews.count > index else { return }
        let view = self.arrangedSubviews[index]
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: { 
            view.alpha = 0
        }, completion: { (_ : Bool) in
            view.removeFromSuperview()
            UIView.animate(withDuration: animated ? 0.2 : 0) {
                self.topMostSuperView.layoutIfNeeded()
            }
        })
    }
    
    /**
     It will remove the given view if present in the arranged subviews array 
     
     - Parameter subview: the view to remove
     - Parameter animated: sliding animation if true, default false
     */
    public func removeSubview(_ subview: UIView, animated: Bool = false) {
        if let index = indexOf(subview: subview) {
            self.removeSubview(at: index, animated: animated)
        }
    } 
    
    /**
     If subview is a view in the arrangedSubviews array, it will remove the view after it if present
     
     - Parameter subview: the view target
     - Parameter animated: sliding animation if true, default false
     */
    public func removeArrangedSubViewAfter(subview: UIView, animated: Bool = false) {
        if let index = indexOf(subview: subview), self.arrangedSubviews.count > index + 1 {
            self.removeSubview(at: index + 1, animated: animated)
        }
    }
    
    /**
     If subview is a view in the arrangedSubviews array, it will remove the view before it if present
     
     - Parameter subview: the view target
     - Parameter animated: sliding animation if true, default false
     */
    public func removeArrangedSubViewBefore(subview: UIView, animated: Bool = false) {
        if let index = indexOf(subview: subview), index - 1 > 0 {
            self.removeSubview(at: index - 1, animated: animated)
        }
    }
}
