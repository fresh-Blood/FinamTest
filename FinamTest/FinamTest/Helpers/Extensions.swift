import UIKit

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

// MARK: images are loading when we see them not on main queue, if the image is huge and loading takes much time - UI doesn't freeze: we can go back and choose another topic

extension UIImageView {
    func downLoadImage(from: String, completion: @escaping () -> Void) {
        if let cachedImage = Cashe.imageCache.object(forKey: from as AnyObject) {
            DispatchQueue.main.async {
                completion()
            }
            self.image = cachedImage
            return
        }
        if let url = URL(string: from) {
            URLSession.shared.dataTask(with: url, completionHandler: { data,response,error in
                if let data = data {
                    DispatchQueue.main.async {
                        guard
                            let unwrappedImage = UIImage(data: data) else { return }
                        Cashe.imageCache.setObject(unwrappedImage, forKey: from as AnyObject)
                        self.image = unwrappedImage
                        completion()
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
    
    func configureShadow(with shadowState: ShadowState? = .set,
                         configureBorder: Bool,
                         withAlpha: CGFloat? = 1) {
        guard shadowState == .set else {
            self.layer.shadowOffset = .zero
            self.layer.shadowOpacity = .zero
            self.layer.shadowColor = .none
            self.layer.shadowRadius = .zero
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = .zero
            return
        }
        if configureBorder {
            self.layer.borderColor = Colors.valueForButtonColor.cgColor
            self.layer.borderWidth = 3
        } 
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 2, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = Colors.valueForButtonColor.withAlphaComponent(withAlpha ?? 1.0).cgColor
        self.layer.shadowRadius = 7
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
        self.layer.mask = gradientLayer
    }
}

extension String {
    func configureNewsTitle() -> String {
        String(self.reversed().drop(while: { $0 != "-" }).dropFirst(1).reversed())
    }
    
    func toReadableDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: self)
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ru_Ru")
        let dayYearInfo = dateFormatter.string(from: date ?? Date())
        dateFormatter.dateFormat = "yyyy-MM-dd в HH:mm"
        let timeInfo = dateFormatter.string(from: date ?? Date()).drop(while: { $0 != " "})
        return dayYearInfo + timeInfo
    }
}

extension UIViewController {
    func prepairForIPad(withVCView: UIView?, withVC: UIViewController?) {
        self.popoverPresentationController?.sourceView = withVCView
        self.popoverPresentationController?.sourceRect = CGRect(origin: withVCView?.center ?? .zero, size: .zero)
        self.popoverPresentationController?.barButtonItem = withVC?.navigationItem.backBarButtonItem
    }
}
