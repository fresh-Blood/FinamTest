import Foundation
import UIKit
import AVKit

typealias Completion = () -> Void

protocol UserInternetService {
    var view: NewsView? { get set }
    var newsArray: [Articles] { get set }
    func getData(with keyWord: String?, category: String?)
}

final class InternetService: UserInternetService {
    private var timer: Timer?
    
    var view: NewsView?
    var newsArray: [Articles] = []
    var loadingNewsTask: Task<(), Error>?
    
    func getData(with keyWord: String?, category: String? = nil) {
        loadingNewsTask?.cancel()
        
        var urlString: String {
            let mode: Mode = keyWord == nil ? .category(category ?? "") : .keyword(keyWord ?? "")
            return getLinkWith(mode)
        }
        
        loadingNewsTask = Task {
            guard let url = URL(string: urlString) else { return }
            
            let (data,response) = try await URLSession.shared.data(from: url)
            
            guard let newsArray = try JSONDecoder().decode(CommonInfo.self, from: data).articles else { return }
            
            self.newsArray = newsArray
            
            guard let response = response as? HTTPURLResponse else { return }
            
            handleResponse(response)
        }
        
        launchTimer()
    }
    
    private func launchTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 7,
                                     repeats: false,
                                     block: { [weak self] _ in
            guard let self else { return }
            loadingNewsTask?.cancel()
            view?.handleResponseFailure(with: Errors.timeout.rawValue)
            invalidateTimer()
        })
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleResponse(_ response: HTTPURLResponse) {
        VibrateManager.shared.impactOccured(.rigid)
        
        switch response.statusCode {
            case HttpStatusCodes.tooManyRequests.rawValue:
                view?.handleResponseFailure(with: Errors.tooManyRequests.rawValue)
            case HttpStatusCodes.internalServerError.rawValue:
                view?.handleResponseFailure(with: Errors.serverError.rawValue)
            case HttpStatusCodes.notFound.rawValue:
                view?.handleResponseFailure(with: Errors.unauthorized.rawValue)
            case HttpStatusCodes.badRequest.rawValue:
                view?.handleResponseFailure(with: Errors.badRequest.rawValue)
            case HttpStatusCodes.ok.rawValue:
                view?.handleResponseSuccess()
            default:
                break
        }
    }
    
    private func getLinkWith(_ mode: Mode) -> String {
        switch mode {
            case .keyword(let keyword):
                return "https://newsapi.org/v2/everything?q=\(keyword)&pageSize=100&language=ru&apiKey=\(DeveloperInfo.apiKey.rawValue)"
            case .category(let category):
                return "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&pageSize=100&apiKey=\(DeveloperInfo.apiKey.rawValue)"
        }
    }
}

final class Cashe {
    static let imageCache = NSCache<AnyObject, UIImage>()
}

