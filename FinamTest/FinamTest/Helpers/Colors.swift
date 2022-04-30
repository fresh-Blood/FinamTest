import UIKit

// MARK: Colors
struct Colors {
    static var valueForColor: UIColor {
        let color: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        return UIColor(named: "valueForColor") ?? color
    }
    
    static var reversedValueForColor: UIColor {
        let color: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        return UIColor(named: "reversedValueForColor") ?? color
    }
    
    static var valueForButtonColor: UIColor {
        let color: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .systemGreen : .systemCyan
        return UIColor(named: "valueForButtonColor") ?? color
    }

    static var valueForGradientAnimation: UIColor {
        let color: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .systemGray3 : .white
        return UIColor(named: "valueForGradientAnimation") ?? color
    }
}
