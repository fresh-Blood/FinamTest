import Foundation
import UIKit


protocol UserController {
    func getData(completion: @escaping () -> Void)
    var view: UserView? { get set }
    var newsArray: [Articles] { get set }
}

final class Controller: UserController {
    
    var view: UserView?
    var newsArray: [Articles] = []
    
    internal func getData(completion: @escaping () -> Void) {
        
        if let url = URL(string: URLs.topHeadLinesTechnology.rawValue) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data {
                    do {
                        let parsedJson = try JSONDecoder().decode(CommonInfo.self, from: data)
                        self?.newsArray = parsedJson.articles ?? []
                        DispatchQueue.main.async {
                            self?.view?.reload()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            completion()
                        }
                    } catch let error{
                        print(error)
                    }
                    if let HTTPResponse = response as? HTTPURLResponse {
                        completion()
                        switch HTTPResponse.statusCode {
                        case 429:
                            self?.view?.animateResponseError(with: Errors.tooManyRequests.rawValue)
                        case 500:
                            self?.view?.animateResponseError(with: Errors.serverError.rawValue)
                        case 401:
                            self?.view?.animateResponseError(with: Errors.unauthorized.rawValue)
                        case 400:
                            self?.view?.animateResponseError(with: Errors.badRequest.rawValue)
                        case 200:
                            fallthrough
                        default:
                            break
                        }
                    }
                }
            }.resume()
        }
    }
}

final class Cashe {
    static let imageCache = NSCache<AnyObject, UIImage>()
}

