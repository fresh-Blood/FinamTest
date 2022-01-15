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

enum CustomURL: String {
    case url = "https://newsapi.org/v2/top-headlines?country=ru&category=technology&apiKey=8f825354e7354c71829cfb4cb15c4893"
}


