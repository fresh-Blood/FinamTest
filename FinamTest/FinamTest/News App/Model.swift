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

enum URLs: String {
    case topHeadLinesTechnology = "https://newsapi.org/v2/top-headlines?country=ru&category=technology&pageSize=100&apiKey=8f825354e7354c71829cfb4cb15c4893"
    case everythingQWithParameters = "https://newsapi.org/v2/everything?q=apple&pageSize=100&language=ru&apiKey=8f825354e7354c71829cfb4cb15c4893"
}

enum ProductKeys: String {
    case forTestFirst = "8f825354e7354c71829cfb4cb15c4893"
    case forTestSecond = "" // Hide
}

enum Errors: String {
    case topicLabelNoInfo = "Тут должно быть описание, но его нет - это не ошибка, попробуйте прочитать подробнее по кнопке ниже."
    case badRequest = "Error 400 - Чёто с интернетом, попробуйте позже"
    case unauthorized = "Error 401 - Чёто с авторизацией запроса, попробуйте позже"
    case tooManyRequests = "Error 429 - Превышено кол-во запросов в сутки (100), возвращайтесь завтра, 50к $ стоит безлимит, увы"
    case serverError = "Error 500 - Ошибка сервера, пойду посплю тогда, мб позже заработает"
    case error = "Какая то ошибка господа и дамы. Инет видимо пока не появился, попробуйте позже."
}

enum InfoMessage: String {
    case infoTitle = "Инфо от разработчика"
    case infoMessage = "Друзья, это мое первое приложение в сторе, которое я выложил для портфолио и опыта - тк это целый процесс, лицензия на 8к запросов к серверу стоит 50к $ в месяц - таких средств пока нет, поэтому при превышении запросов (более 100 в сутки) Вы получите соответствующую ошибку. Кол - во запросов обнуляется раз в сутки. Поэтому прошу не судите строго и не ставьте низкие оценки за это. Если есть что то еще - буду рад критике или похвале :)"
}
