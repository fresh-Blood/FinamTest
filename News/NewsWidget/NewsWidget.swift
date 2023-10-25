//
//  NewsWidget.swift
//  NewsWidget
//
//  Created by Ярослав Куприянов on 25.10.2023.
//

import WidgetKit
import SwiftUI

extension String {
    func getDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_En")
        return dateFormatter.date(from: self) ?? Date()
    }
}

enum Categories: String, CaseIterable {
    static var random: String {
        Categories.allCases.randomElement()?.rawValue ?? ""
    }
    
    case business
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
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

struct CommonInfo : Decodable {
    var status : String?
    var totalResults : Int?
    var articles : [Articles]?
}

struct Entry: TimelineEntry {
    let date: Date
    let category: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), category: "")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), category: "Category")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let category = Categories.random
            guard let posted = try? await getTime(category: category) else { return }
            let entry = Entry(date: posted, category: category)
            guard let nextUpdate = Calendar.current.date(byAdding: DateComponents(minute: 360),
                                                         to: Date()) else { return }
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    func getTime(category: String) async throws -> Date {
        let link = "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&pageSize=100&apiKey=8f825354e7354c71829cfb4cb15c4893"
        
        guard let url = URL(string: link) else { return Date() }
        let (data, _) = try await URLSession.shared.data(from: url)
        let model = try JSONDecoder().decode(CommonInfo.self, from: data)
        let date = model.articles?.first?.publishedAt?.getDate()
        return date ?? Date()
    }
}

struct NewsWidgetEntryView : View {
    let entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("Category:")
                .fontDesign(.monospaced)
                .font(.headline)
            
            Text(entry.category)
                .fontDesign(.monospaced)
            
            Text("Posted:")
                .padding(.top, 6)
                .fontDesign(.monospaced)
                .font(.headline)
            
            Text(entry.date, style: .time)
                .fontDesign(.monospaced)
                .font(.title3)
        }
        .transition(.push(from: .bottom))
    }
}

struct NewsWidget: Widget {
    let kind: String = "NewsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NewsWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
                
            } else {
                NewsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("News widget")
        .description("Stay in touch")
    }
}

#Preview(as: .systemSmall) {
    NewsWidget()
} timeline: {
    Entry(date: .now, category: Categories.random)
}
