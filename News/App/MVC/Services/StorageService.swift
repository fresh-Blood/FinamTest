import Foundation


struct StorageService {
    
    static let shared = StorageService()
    
    var selectedCategory: Categories.RawValue {
        StorageService.shared.get(Categories.key) ?? Categories.technology.rawValue
    }
    
    private let defaults = UserDefaults.standard
    
    func getBool(for key: String) -> Bool? {
        defaults.value(forKey: key) as? Bool
    }
    
    func save(_ bool: Bool, forKey: String) {
        defaults.set(bool, forKey: forKey)
    }
    
    func save(_ string: String, forKey: String) {
        defaults.set(string, forKey: forKey)
    }
    
    func get(_ string: String) -> String? {
        defaults.value(forKey: string) as? String
    }
    
    func checkIfViewed(with id: String) -> Bool {
        let key = "viewedNews"
        var viewedNews = defaults.stringArray(forKey: key)
        
        guard viewedNews == nil else {
            
            if viewedNews?.contains(where: { $0 == id }) ?? false {
                return true
            } else {
                
                if viewedNews?.count == Constants.dataStorageSize {
                    viewedNews?.removeLast()
                }
                
                viewedNews?.append(id)
                defaults.set(viewedNews, forKey: key)
                return false
            }
        }
        
        defaults.set([id], forKey: key)
        
        return false
    }
}

private enum Constants {
    static let newsCount = 100
    static let dataStorageSize = Categories.allCases.count * newsCount
}
