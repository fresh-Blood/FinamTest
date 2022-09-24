import Foundation


struct StorageService {
    
    static let shared = StorageService()
    
    func getData(for key: String) -> Bool? {
        UserDefaults.standard.value(forKey: key) as? Bool
    }
    
    func saveData(with value: Bool, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func saveAppVersion(_ currentVersion: String) {
        UserDefaults.standard.set(currentVersion, forKey: currentVersion)
    }
    
    func getAppVersion(_ currentVersion: String) -> String? {
        UserDefaults.standard.value(forKey: currentVersion) as? String
    }
}
