import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

extension UIStackView {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        return false
    }
}

extension UIView {
    func pulsate() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.98
        animation.toValue = 1
        animation.damping = 1.0
        animation.duration = 0.2
        layer.add(animation, forKey: nil)
    }
}

extension UIImageView {
    func downLoadImage(from: String, completion: Action? = nil) {
        if let cachedImage = Cache.imageCache.object(forKey: from as AnyObject) {
            DispatchQueue.main.async {
                completion?()
            }
            image = cachedImage
            return
        }
        
        if let url = URL(string: from) {
            URLSession.shared.dataTask(with: url, completionHandler: { data,response,error in
                if let data = data {
                    DispatchQueue.main.async {
                        guard
                            let unwrappedImage = UIImage(data: data) else { return }
                        Cache.imageCache.setObject(unwrappedImage, forKey: from as AnyObject)
                        self.image = unwrappedImage
                        completion?()
                    }
                }
            }).resume()
        }
    }
}

extension UIView {
    enum ShadowState {
        case set
        case removed
    }
    
    func animatePressing(gesture: UILongPressGestureRecognizer, completion: Action?) {
        if gesture.state == .began {
            UIView.animate(withDuration: 1,
                           delay: .zero,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: .zero,
                           options: .curveEaseInOut,
                           animations: {
                self.configureShadow(configureBorder: true)
                self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            })
            
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.5,
                           delay: .zero,
                           animations: {
                self.transform = .identity
                self.configureShadow(with: .removed, configureBorder: false)
                
            }, completion: { _ in
                completion?()
                VibrateManager.shared.impactOccured(.rigid)
            })
        }
    }
    
    func configureShadow(with shadowState: ShadowState? = .set,
                         configureBorder: Bool,
                         withAlpha: CGFloat? = 1,
                         shadowColor: UIColor? = Colors.valueForButtonColor)
    {
        guard shadowState == .set else {
            layer.shadowOffset = .zero
            layer.shadowOpacity = .zero
            layer.shadowColor = .none
            layer.shadowRadius = .zero
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = .zero
            return
        }
        
        if configureBorder {
            layer.borderColor = shadowColor?.cgColor
            layer.borderWidth = 3
        }
        
        layer.cornerRadius = 16
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowOpacity = 1.0
        layer.shadowColor = shadowColor?.withAlphaComponent(withAlpha ?? 1.0).cgColor
        layer.shadowRadius = 10
    }
    
    func animateGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            Colors.valueForGradientAnimation.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [ 0.25, 0.5, 0.75 ]
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 3
        animation.fromValue = [0.0, 0.0, 0.25]
        animation.toValue = [0.75, 1.0, 1.0]
        animation.repeatCount = Float.infinity
        gradientLayer.add(animation, forKey: "skeleton's nice animation")
        gradientLayer.frame = CGRect(x: -bounds.size.width,
                                     y: bounds.origin.y,
                                     width: bounds.size.width * 4,
                                     height: bounds.size.height)
        layer.mask = gradientLayer
    }
}

extension String {
    func configureNewsTitle() -> String {
        String(self.reversed().drop(while: { $0 != "-" }).dropFirst(1).reversed())
    }
    
    func toReadableDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_En")
        
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        return dateFormatter.string(from: date!)
    }
}

extension UIViewController {
    func prepairForIPad(withVCView: UIView?, withVC: UIViewController?) {
        popoverPresentationController?.sourceView = withVCView
        popoverPresentationController?.sourceRect = CGRect(origin: withVCView?.center ?? .zero, size: .zero)
        popoverPresentationController?.barButtonItem = withVC?.navigationItem.backBarButtonItem
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let imageData = try? Data(contentsOf: bundleURL)
        else { return nil }
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.05
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self
        )
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self
        )
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(
                CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                to: AnyObject.self
            )
        }
        
        delay = delayObject as! Double
        
        if delay < 0.05 {
            delay = 0.05
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0))
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
}

extension UIViewController {
    func injectCloseButton() {
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close),
                              for: .touchUpInside)
        closeButton.backgroundColor = .clear
        let closeButtonSize: CGFloat = 50
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: .zero),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: .zero),
            closeButton.widthAnchor.constraint(equalToConstant: closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: closeButtonSize)
        ])
    }
    
    @objc func close() {
        guard let presentedViewController else { return }
        presentedViewController.dismiss(animated: true)
    }
}
