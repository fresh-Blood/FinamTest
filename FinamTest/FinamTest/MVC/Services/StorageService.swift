import Foundation


struct StorageService {
    
    static let shared = StorageService()
    
    var selectedCategory: Categories.RawValue {
        StorageService.shared.get(Categories.key) ?? Categories.technology.rawValue
    }
    
    func getBool(for key: String) -> Bool? {
        UserDefaults.standard.value(forKey: key) as? Bool
    }
    
    func save(_ bool: Bool, forKey: String) {
        UserDefaults.standard.set(bool, forKey: forKey)
    }
    
    func save(_ string: String, forKey: String) {
        UserDefaults.standard.set(string, forKey: forKey)
    }
    
    func get(_ string: String) -> String? {
        UserDefaults.standard.value(forKey: string) as? String
    }
}
