import Foundation
import UIKit

typealias Completion = () -> Void

protocol UserInternetService {
    func getData(completion: @escaping Completion, with keyWord: String?) async throws
    var view: UserView? { get set }
    var newsArray: [Articles] { get set }
}

final class InternetService: UserInternetService {
    
    private var timer = Timer()
    var view: UserView?
    var newsArray: [Articles] = []
    
    func getData(completion: @escaping Completion, with keyWord: String?) async throws {
        
        var urlString: String {
            keyWord != nil ?
            "https://newsapi.org/v2/everything?q=\(keyWord ?? "")&pageSize=100&language=ru&apiKey=8f825354e7354c71829cfb4cb15c4893"
            :
            URLs.topHeadLinesTechnology.rawValue
        }
        timer = Timer.scheduledTimer(withTimeInterval: 7, repeats: false, block: { [weak self] _ in
            guard let newsArray = self?.newsArray else { return }
            if newsArray.isEmpty {
                self?.view?.animateResponseError(with: Errors.error.rawValue)
                completion()
                self?.timer.invalidate()
            }
        })
        guard let url = URL(string: urlString) else { return }
        let (data,response) = try await URLSession.shared.data(from: url)
        
        guard let newsArray = try JSONDecoder().decode(CommonInfo.self, from: data).articles else { return }
        self.newsArray = newsArray
        
        guard let httpResponse = response as? HTTPURLResponse else { return }
        completion()
        handleResponse(httpResponseStatusCode: httpResponse.statusCode)
        
        DispatchQueue.main.async { [weak self] in
            self?.view?.reload()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            completion()
        }
    }
    
    private func handleResponse(httpResponseStatusCode: Int) {
        switch httpResponseStatusCode {
        case 429:
            view?.animateResponseError(with: Errors.tooManyRequests.rawValue)
        case 500:
            view?.animateResponseError(with: Errors.serverError.rawValue)
        case 401:
            view?.animateResponseError(with: Errors.unauthorized.rawValue)
        case 400:
            view?.animateResponseError(with: Errors.badRequest.rawValue)
        case 200:
            view?.animateGoodConnection()
        default:
            break
        }
    }
}

final class Cashe {
    static let imageCache = NSCache<AnyObject, UIImage>()
}

