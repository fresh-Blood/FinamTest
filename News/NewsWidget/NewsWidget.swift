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

extension Date {
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_En")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self)
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

struct SmallView: View {
    let entry: Provider.Entry

    var body: some View {
        ZStack {
            Image("blur")
                .resizable()
                .frame(width: 200, height: 170)
            VStack {
                Text(entry.category)
                    .fontDesign(.monospaced)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                Text(entry.date, style: .time)
                    .fontDesign(.monospaced)
                    .font(.title)
                    .foregroundStyle(.gray)
            }
            .padding(EdgeInsets(top: -70,
                                leading: 40,
                                bottom: 0,
                                trailing: 20))
        }
    }
}

struct AccessoryCircularView: View {
    let entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Color.black.clipShape(.circle)
            VStack {
                Text(entry.category)
                    .fontDesign(.monospaced)
                    .font(.system(size: 11))
                    .padding(EdgeInsets(top: .zero,
                                        leading: 7,
                                        bottom: .zero,
                                        trailing: 7))
                    .lineLimit(1)
                Text(entry.date, style: .time)
                    .fontDesign(.monospaced)
                    .font(.system(size: 13))
                    .padding(EdgeInsets(top: -3,
                                        leading: 7,
                                        bottom: .zero,
                                        trailing: 7))
            }
        }
    }
}

struct AccessoryInlineView: View {
    let entry: Provider.Entry
    
    var body: some View {
        Text(entry.category + " " +  entry.date.getTime())
            .fontDesign(.monospaced)
            .lineLimit(1)
    }
}

struct AccessoryRectangularView: View {
    let entry: Provider.Entry
    
    var body: some View {
        Text(entry.category)
            .fontDesign(.monospaced)
            .font(.system(size: 25))
            .lineLimit(1)
        
        Text(entry.date.getTime())
            .fontDesign(.monospaced)
            .font(.system(size: 25))
            .lineLimit(1)
    }
}

struct NewsWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    let entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        VStack {
            switch family {
                case .systemSmall: SmallView(entry: entry)
                case .accessoryCircular: AccessoryCircularView(entry: entry)
                case .accessoryInline: AccessoryInlineView(entry: entry)
                case .accessoryRectangular: AccessoryRectangularView(entry: entry)
                default:
                    Text("Need configure")
                        .fontDesign(.monospaced)
                        .font(.headline)
            }
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
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
        ])
    }
}

#Preview(as: .systemSmall) {
    NewsWidget()
} timeline: {
    Entry(date: .now, category: Categories.random)
}
