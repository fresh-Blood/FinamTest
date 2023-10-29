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
    var viewed: Bool?
}

struct Source : Decodable {
    var id : String?
    var name : String?
}

enum Categories: String, CaseIterable {
    static var title: String {
        "Please choose news category"
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
    case badRequest = "Error 400\n\nBad request, please try again later"
    case unauthorized = "Error 401\n\nRequest autorization failed, please try again later"
    case tooManyRequests = "Error 429\n\nRequests number per day exceeded, see you tommorow"
    case serverError = "Error 500\n\nServer error, please try again later"
    case timeout = "Time - out\nerror\n\nServer problem or internet connection broken"
}

enum DeveloperInfo: String {
    case appTitle = "News"
    case shareInfo = "Stay in touch 🤙🏽 ➡️ _link to appStore_"
    case apiKey = "8f825354e7354c71829cfb4cb15c4893"
}

enum Updates: String {
    case title = "What's new:"
    case whatsNew = "- Interface boosted\n- Bugs fixed\n- Settings screen redone\n- Category setting added\n- Shortcuts added\n- Widgets added\n- Lock screen widgets added\n- Notifications added\n- Kitten now lives inside"
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
    case newsCategory = "Category"
    case appVerstion = "Version"
    case settings = "Settings"
}

enum Other: String {
    case moreInfo = "More"
}

enum AppVersion {
    static let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Error in recognizing appVersion"
}

enum Mode {
    case keyword(_ : String)
    case category(_ : String)
}

enum HttpStatusCodes: Int {
    case badRequest = 400
    case internalServerError = 500
    case notFound = 401
    case ok = 200
    case tooManyRequests = 429
}
