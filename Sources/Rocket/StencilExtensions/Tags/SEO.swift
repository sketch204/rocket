import Foundation
import Stencil

extension CustomTags {
    enum SEO {
        static let formatter: DateFormatter = {
            let output = DateFormatter()
            output.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            return output
        }()
        
        fileprivate enum PageType: String {
            case article
            case website
            case profile
        }
        
        static func makeExtension(with config: Config) -> Extension {
            let ext = Extension()
            
            ext.registerSimpleTag("seo") { context in
                generateContent(
                    config: config,
                    pageContext: Context(dictionary: context.flatten())
                )
            }
            return ext
        }
        
        static func generateContent(
            config: Config,
            pageContext: Context
        ) -> String {
            guard let seoContext = seoContext(from: config, context: pageContext) else { return "" }
            
            let pageContext = pageContext.context(.page)
            let pageType = pageType(from: pageContext)
            
            func value(for key: String) -> String? {
                pageContext?[key] as? String
                    ?? seoContext[key] as? String
            }
            
            func subContext(for key: String) -> Context? {
                pageContext?.context(key) ?? seoContext.context(key)
            }
            
            var output: [Tag] = []
            
            if let title = value(for: "title") {
                output.append(TitleTag(title: title))
                output.append(MetaTag(property: "og:title", content: title))
            }
            
            if let description = value(for: "description") {
                output.append(MetaTag(property: "og:description", content: description))
                output.append(MetaTag(name: "description", content: description))
            }
            
            let locale = value(for: "locale") ?? "en_US"
            output.append(MetaTag(property: "og:locale", content: locale))
            
            if let outputPath = pageContext?[.outputPath],
               var siteUrl = seoContext["siteURL"] as? String
            {
                if siteUrl.hasSuffix("/") {
                    siteUrl.removeLast()
                }
                let outputUrl = "\(siteUrl)\(outputPath)"
                
                output.append(LinkTag(href: outputUrl))
                output.append(MetaTag(property: "og:url", content: outputUrl))
            }
            
            if let siteTitle = seoContext["title"] as? String {
                output.append(MetaTag(property: "og:site_name", content: siteTitle))
            }
            
            output.append(MetaTag(property: "og:type", content: pageType.rawValue))
            
            output.append(MetaTag(name: "generator", content: "Rocket"))
            
            if let tags = pageContext?["tags"] as? [String] {
                output.append(contentsOf: tags.map({
                    MetaTag(property: "article:tag", content: $0)
                }))
            }
            
            if pageType == .article, let date = pageContext?[.date] as? Date {
                output.append(MetaTag(property: "article:published_time", content: formatter.string(from: date)))
            }
            
            if let author = value(for: "author") {
                output.append(MetaTag(name: "author", content: author))
            }
            
            if pageType == .profile, let author = subContext(for: "author") {
                if let firstName = author["firstName"] as? String {
                    output.append(MetaTag(name: "profile:first_name", content: firstName))
                }
                if let lastName = author["lastName"] as? String {
                    output.append(MetaTag(name: "profile:last_name", content: lastName))
                }
                if let username = author["username"] as? String {
                    output.append(MetaTag(name: "profile:username", content: username))
                }
            }
            
            return output.map(\.html).joined(separator: "\n")
        }
        
        private static func pageType(from pageContext: Context?) -> PageType {
            let isPost = (pageContext?[.isPost] as? Bool) ?? false
            
            let rawOverrideType = (pageContext?["type"] as? String)?.lowercased()
            let type = rawOverrideType.flatMap(PageType.init(rawValue:))
            
            return type ?? (isPost ? .article : .website)
        }
        
        private static func seoContext(from config: Config, context: Context) -> Context? {
            if let output = context.context("seo") {
                output
            } else if let seo = config.userProperties["seo"] as? [String: Any] {
                Context(dictionary: seo)
            } else {
                nil
            }
        }
    }
}

/*
 
 <script type="application/ld+json">
 {
 "@context":"https://schema.org",
 "@type":"WebSite",
 "author":{
    "@type":"Person",
    "name":"Inal Gotov"
 },
 "description":"Inal’s personal webpage!",
 "headline":"Inal Gotov",
 "name":"Inal Gotov",
 "url":"https://inalgotov.com/"
 }</script>

 
 <script type="application/ld+json">
 {
 "@context":"https://schema.org",
 "@type":"BlogPosting",
 "author":{
    "@type":"Person",
    "name":"Inal Gotov"
 },
 "dateModified":"2023-09-07T00:00:00+00:00",
 "datePublished":"2023-09-07T00:00:00+00:00",
 "description":"An in-depth look at how Tables are implemented in SwiftUI",
 "headline":"How to use Tables in SwiftUI",
 "mainEntityOfPage":{
    "@type":"WebPage",
    "@id":"https://inalgotov.com/2023/09/07/how-to-use-tables-in-swiftui.html"
 },
 "url":"https://inalgotov.com/2023/09/07/how-to-use-tables-in-swiftui.html"
 }</script>
*/



// MARK: Tags

fileprivate protocol Tag {
    var html: String { get }
}

extension CustomTags.SEO {
    fileprivate struct TitleTag: Tag {
        var title: String
        
        var html: String { "<title>\(title)</title>" }
    }
    
    fileprivate struct LinkTag: Tag {
        enum Relationship: String {
            case canonical
        }
        
        var href: String
        var relationship: Relationship = .canonical
        
        var html: String {
            "<link rel=\"\(relationship.rawValue)\" href=\"\(href)\" />"
        }
    }
    
    fileprivate struct MetaTag: Tag {
        var property: String?
        var name: String?
        var content: String?
        
        var html: String {
            let attributes = [
                name.map { "name=\"\($0)\"" },
                property.map { "property=\"\($0)\"" },
                content.map { "content=\"\($0)\"" },
            ]
            .compactMap { $0 }
            .joined(separator: " ")
            
            return "<meta \(attributes) />"
        }
    }
}
