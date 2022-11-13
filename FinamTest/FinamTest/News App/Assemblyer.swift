import Foundation
import UIKit

typealias EntryPoint = UserView & UIViewController

protocol Assemblyer {
    var entry: EntryPoint? { get }
    static func start() -> Assemblyer
}

final class UserAssemblyer: Assemblyer {
    var entry: EntryPoint?
    static func start() -> Assemblyer {
        let assemblyer = UserAssemblyer()
        let view = NewsViewController()
        let internetService = InternetService()
        view.internetService = internetService
        internetService.view = view
        assemblyer.entry = view as EntryPoint
        return assemblyer
    }
}
