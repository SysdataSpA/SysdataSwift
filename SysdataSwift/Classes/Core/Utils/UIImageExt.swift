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

extension UIImage {
    
    /**
     It tells if image has come content or is completely empty (no pixels at all, aka UIImage())
     
     - Returns: true if the image has some content
    */
    public var hasContent: Bool {
        return cgImage != nil || ciImage != nil
    }
    
    /**
     Fusion of two images one into another
     
     - Parameter bottomImage: the image in background
     - Parameter topImage: the image in foreground
     
     - Returns: the fusion of the two images
     */
    public static func blend(bottomImage: UIImage, topImage: UIImage) -> UIImage {
        let width = bottomImage.size.width
        let height = bottomImage.size.height
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let imgView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imgView.contentMode = .scaleAspectFill
        imgView2.contentMode = .center
        imgView.image = bottomImage
        imgView2.image = topImage
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        contentView.addSubview(imgView)
        contentView.addSubview(imgView2)
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        if let context = UIGraphicsGetCurrentContext() {
            contentView.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    /**
     Creation of an image from a color
     
     - Parameter color: the color for the image
     - Parameter size: size of the resulting image
     - Parameter fill: if the image should be filled with color or just outlined, defualt true
     - Parameter cornerRadius: the corner radius to use, default 0
     - Parameter lineWidth: the width of the border, default 0
     - Parameter inset: the inset from all the borders of the image, default 0
     
     - Returns: the fusion of the two images
     */
    public static func with(color: UIColor, size: CGSize, fill: Bool = true, cornerRadius: CGFloat = 0.0, lineWidth: CGFloat = 0.0, inset: CGFloat = 0) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width + lineWidth, height: size.height + lineWidth)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let rectStroke: CGRect = CGRect(x: 0 + lineWidth / 2, y: 0 + lineWidth / 2, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rectStroke, cornerRadius: cornerRadius)
        path.lineWidth = lineWidth
        color.setStroke()
        path.stroke()
        if fill {
            let rectFill: CGRect = CGRect(x: 0 + inset + lineWidth / 2, y: 0 + inset + lineWidth / 2, width: size.width - inset * 2, height: size.height - inset * 2)
            let path = UIBezierPath(roundedRect: rectFill, cornerRadius: cornerRadius)
            color.setFill()
            path.fill()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    /**
     Creation of a copy of the given image with a colored transparent layer applied over
     
     - Parameter color: the color for the overlay
     
     - Returns: the resulting image
     */
    public func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        if let image = self.cgImage {
            context?.clip(to: rect, mask: image)
        }
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    /**
     Creation of an image with the same aspect ratio but resized with the given width
     
     - Parameter width: the resulting image width
     
     - Returns: the resulting image
     */
    public func resizedProportionally(width: CGFloat) -> UIImage {
        let scale = width / size.width
        return self.resized(scale: scale)
    }
    
    /**
     Creation of an image with the same aspect ratio but resized with the given height
     
     - Parameter height: the resulting image height
     
     - Returns: the resulting image
     */
    public func resizedProportionally(height: CGFloat) -> UIImage {
        let scale = height / size.height
        return self.resized(scale: scale)
    }
    
    /**
     Creation of an image with the same aspect ratio but resized with the given scale
     
     - Parameter scale: the resulting image will have width and height scaled by this factor
     
     - Returns: the resulting image
     */
    public func resized(scale: CGFloat) -> UIImage {
        let canvasSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resized(canvasSize)
    }
    
    /**
     Creation of an image resized with the given size: it won't respect the aspect ratio
     
     - Parameter size: the resulting image size
     
     - Returns: the resulting image
     */
    public func resized(_ size: CGSize) -> UIImage {
        if !hasContent { return UIImage() }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    /**
     It tells if the image is portrait (height > width)
     */
    public var isPortrait: Bool {
        return self.size.width < self.size.height
    }
    
    /**
     It tells if the image is landscape (width > height)
     */
    public var isLandscape: Bool {
        return self.size.width > self.size.height
    }
}
