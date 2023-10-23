import Foundation

struct CommonInfo : Decodable {
    var status : String?
    var totalResults : Int?
    var articles : [Articles]?
}

struct Articles : Decodable {
    var source : Source?
    var author : String?
    var title : String?
    var description : String?
    var url : String?
    var urlToImage : String?
    var publishedAt : String?
    var content : String?
}

struct Source : Decodable {
    var id : String?
    var name : String?
}

enum Categories: String, CaseIterable {
    static var title: String {
        "Please choose new theme"
    }
    
    static var key: String {
        String(describing: self)
    }
    
    case business
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
}

enum Errors: String {
    case topicLabelNoInfo = "Should be description here, but none. It's not an error, please use button below to read more"
    case badRequest = "Error 400 - Bad request, please try again later"
    case unauthorized = "Error 401 - Request autorization failed, please try again later"
    case tooManyRequests = "Error 429 - Requests number per day exceeded, see you tommorow"
    case serverError = "Error 500 - Server error, please try again later"
    case error = "Error, please try again later"
}

enum DeveloperInfo: String {
    case appTitle = "News"
    case shareInfo = "Load news, stay in touch 🤙🏽 ➡️ _link to appStore_"
}

enum Updates: String {
    case title = "What's new:"
    case whatsNew = "- New appearance\n- Bugs fixed\n- Settings screen redone\n- Kitten now lives here"
    case ok = "OK"
}

enum SoundName: String {
    case loaded
    case error
    case jedy1
    case jedy2
}

enum GifName: String {
    case kitten
}

enum SettingsKeys: String {
    case soundSettings = "Sounds"
    case newsTheme = "News theme"
    case appVerstion = "Version"
    case settings = "Settings"
}

enum Other: String {
    case moreInfo = "More"
}

enum AppVersion {
    static let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Error in recognizing appVersion"
}
