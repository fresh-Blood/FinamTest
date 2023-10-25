import Foundation
import UIKit
import AVKit

typealias Completion = () -> Void

protocol UserInternetService {
    var view: NewsView? { get set }
    var newsArray: [Articles] { get set }
    func getData(completion: @escaping Completion, with keyWord: String?, category: String?) async throws
}

final class InternetService: UserInternetService {
    private var timer = Timer()
    
    var view: NewsView?
    var newsArray: [Articles] = []
    
    func getData(completion: @escaping Completion, with keyWord: String?, category: String? = nil) async throws {
        
        var urlString: String {
            keyWord != nil ?
            "https://newsapi.org/v2/everything?q=\(keyWord ?? "")&pageSize=100&language=ru&apiKey=8f825354e7354c71829cfb4cb15c4893"
            :
            "https://newsapi.org/v2/top-headlines?country=us&category=\(category ?? "")&pageSize=100&apiKey=8f825354e7354c71829cfb4cb15c4893"
        }
        timer = Timer.scheduledTimer(withTimeInterval: 7, repeats: false, block: { [weak self] _ in
            guard let newsArray = self?.newsArray else { return }
            if newsArray.isEmpty {
                self?.view?.handleResponseFailure(with: Errors.error.rawValue)
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
            VibrateManager.shared.impactOccured(.rigid)
            completion()
        }
    }
    
    private func handleResponse(httpResponseStatusCode: Int) {
        switch httpResponseStatusCode {
            case 429:
                view?.handleResponseFailure(with: Errors.tooManyRequests.rawValue)
            case 500:
                view?.handleResponseFailure(with: Errors.serverError.rawValue)
            case 401:
                view?.handleResponseFailure(with: Errors.unauthorized.rawValue)
            case 400:
                view?.handleResponseFailure(with: Errors.badRequest.rawValue)
            case 200:
                view?.handleResponseSuccess()
            default:
                break
        }
    }
}

final class Cashe {
    static let imageCache = NSCache<AnyObject, UIImage>()
}

