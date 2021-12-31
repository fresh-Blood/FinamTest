import Foundation
import UIKit




protocol UserController {
    func getData()
    var view: UserView? { get set }
    var newsArray: [Articles] { get set }
}
// MARK: если представить, что мы бы использовали VIPER, то это как интернет сервис интерактора - ходит в инет, забирает данные, можно было бы красиво сделать в замыкании сразу их возврат в @escaping, но вью не должен хранить данные, поэтому решил сделать хранилице - массив тут.
final class Controller: UserController {
    
    var view: UserView?
    var newsArray: [Articles] = []
    
    internal func getData() {
        
        if let url = URL(string: CustomURL.url.rawValue) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data {
                    do {
                        let parsedJson = try JSONDecoder().decode(CommonInfo.self, from: data)
                        self?.newsArray = parsedJson.articles ?? []
                        DispatchQueue.main.async {
                            self?.view?.reload()
                        }
                    } catch let error{
                        print(error)
                    }
                }
            }.resume()
        }
    }
}

final class Cashe {
    static let imageCache = NSCache<AnyObject, UIImage>()
}
