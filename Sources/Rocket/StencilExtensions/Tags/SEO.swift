import Foundation
import Stencil

fileprivate extension Context.Key {
    // Common Keys
    static let title = Self(rawValue: "title")
    static let description = Self(rawValue: "description")
    static let author = Self(rawValue: "author")
    
    // SEO Context Keys
    static let siteURL = Self(rawValue: "siteURL")
    static let locale = Self(rawValue: "locale")
    
    // Page Keys
    static let type = Self(rawValue: "pageType")
    static let excerpt = Self(rawValue: "excerpt")
    static let tags = Self(rawValue: "tags")
    
    // Author keys
    static let firstName = Self(rawValue: "firstName")
    static let lastName = Self(rawValue: "lastName")
    static let username = Self(rawValue: "username")
}

extension CustomTags {
    struct SEO {
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
        
        let config: Config
        let seoContext: Context
        let context: Context
        
        var pageContext: Context? {
            context.context(.page)
        }
        fileprivate var pageType: PageType {
            let isPost = (pageContext?[.isPost] as? Bool) ?? false
            
            let rawOverrideType = (pageContext?[.type] as? String)?.lowercased()
            let type = rawOverrideType.flatMap(PageType.init(rawValue:))
            
            return type ?? (isPost ? .article : .website)
        }
        var canonicalUrl: String? {
            guard let outputPath = pageContext?[.outputPath],
                  var siteUrl = seoContext[.siteURL] as? String
            else { return nil }
            
            if siteUrl.hasSuffix("/") {
                siteUrl.removeLast()
            }
            return "\(siteUrl)\(outputPath)"
        }
        
        private init(config: Config, seoContext: Context, context: Context) {
            self.config = config
            self.seoContext = seoContext
            self.context = context
        }
        
        func value(for key: Context.Key) -> String? {
            value(for: key.rawValue)
        }
        
        func value(for key: String) -> String? {
            pageContext?[key] as? String
                ?? seoContext[key] as? String
        }
        
        func subContext(for key: Context.Key) -> Context? {
            subContext(for: key.rawValue)
        }
        
        func subContext(for key: String) -> Context? {
            pageContext?.context(key) ?? seoContext.context(key)
        }
        
        func generateContent() -> String {
            var output: [Tag] = []
            
            output.append(contentsOf: generateTitleTags())
            output.append(contentsOf: generateDescriptionTags())
            output.append(contentsOf: generateCanonicalUrlTags())
            output.append(contentsOf: generateArticleTags())
            output.append(contentsOf: generateAuthorTags())
            output.append(contentsOf: generateMiscTags())
            if let linkedJson = generateLinkedJsonData() {
                output.append(linkedJson)
            }
            
            return output.map(\.html).joined(separator: "\n")
        }
        
        private func generateTitleTags() -> [Tag] {
            var output = [Tag]()
            if let title = value(for: .title) {
                output.append(TitleTag(title: title))
                output.append(MetaTag(property: "og:title", content: title))
            }
            return output
        }
        
        private func generateDescriptionTags() -> [Tag] {
            var output = [Tag]()
            if let description = value(for: .description) {
                output.append(MetaTag(property: "og:description", content: description))
                output.append(MetaTag(name: "description", content: description))
            }
            return output
        }
        
        private func generateCanonicalUrlTags() -> [Tag] {
            var output = [Tag]()
            if let canonicalUrl = canonicalUrl {
                output.append(LinkTag(href: canonicalUrl))
                output.append(MetaTag(property: "og:url", content: canonicalUrl))
            }
            return output
        }
        
        private func generateAuthorTags() -> [Tag] {
            var output = [Tag]()
            if let author = value(for: .author) {
                output.append(MetaTag(name: "author", content: author))
            }
            else if let author = subContext(for: .author) {
                let firstName = author[.firstName] as? String
                let lastName = author[.lastName] as? String
                
                let fullName = [firstName, lastName].compactMap({ $0 }).joined(separator: " ")
                
                if !fullName.isEmpty {
                    output.append(MetaTag(name: "author", content: fullName))
                }
                
                if pageType == .profile {
                    if let firstName {
                        output.append(MetaTag(name: "profile:first_name", content: firstName))
                    }
                    if let lastName {
                        output.append(MetaTag(name: "profile:last_name", content: lastName))
                    }
                    if let username = author[.username] as? String {
                        output.append(MetaTag(name: "profile:username", content: username))
                    }
                }
            }
            return output
        }
        
        private func generateArticleTags() -> [Tag] {
            var output = [Tag]()
            
            if let tags = pageContext?[.tags] as? [String] {
                output.append(contentsOf: tags.map({
                    MetaTag(property: "article:tag", content: $0)
                }))
            }
            
            if pageType == .article, let date = pageContext?[.date] as? Date {
                output.append(MetaTag(property: "article:published_time", content: Self.formatter.string(from: date)))
            }
            
            return output
        }
        
        private func generateMiscTags() -> [Tag] {
            var output = [Tag]()
            
            output.append(MetaTag(property: "og:type", content: pageType.rawValue))
            
            if let siteTitle = seoContext[.title] as? String {
                output.append(MetaTag(property: "og:site_name", content: siteTitle))
            }
            
            let locale = value(for: .locale) ?? "en_US"
            output.append(MetaTag(property: "og:locale", content: locale))
            
            output.append(MetaTag(name: "generator", content: "Rocket"))
            
            return output
        }
        
        private func generateLinkedJsonData() -> Tag? {
            let author: LinkedJSON.Person? =
            if let author = subContext(for: .author),
               let firstName = author[.firstName] as? String,
               let lastName = author[.lastName] as? String
            {
                LinkedJSON.Person(firstName: firstName, lastName: lastName)
            } else {
                nil
            }
            
            let linkedJsonData: LinkedJSONData
            switch pageType {
            case .article:
                guard let canonicalUrl, 
                        let title = value(for: .title),
                      let date = pageContext?[.date] as? Date
                else { return nil }
                
                linkedJsonData = LinkedJSON.BlogPosting(
                    name: title,
                    author: author,
                    datePublished: date,
                    description: value(for: .description),
                    headline: value(for: .excerpt),
                    url: canonicalUrl,
                    keywords: pageContext?[.tags] as? [String]
                )
            case .website:
                guard let canonicalUrl, let title = value(for: .title) else { return nil }
                
                linkedJsonData = LinkedJSON.WebSite(
                    author: author,
                    description: value(for: .description),
                    headline: value(for: .excerpt),
                    name: title,
                    url: canonicalUrl
                )
            case .profile:
                guard let author else { return nil }
                
                linkedJsonData = author
            }
            
            let linkedJson = LinkedJSON(data: linkedJsonData)
            
            do {
                let html = try linkedJson.html
                return RawTag(html: html)
            } catch {
                print("WARNING: Failed to generate Linked Data JSON due to error! \(error)")
                return nil
            }
        }
    }
}


// MARK: Extension

extension CustomTags.SEO {
    static func makeExtension(with config: Config) -> Extension {
        let ext = Extension()
        
        ext.registerSimpleTag("seo") { context in
            generateContent(with: config, context: Context(dictionary: context.flatten()))
        }
        return ext
    }
    
    static func generateContent(with config: Config, context: Context) -> String {
        guard let seoContext = seoContext(from: config, context: context) else { return "" }
        
        return Self.init(config: config, seoContext: seoContext, context: context).generateContent()
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


// MARK: Tags

fileprivate protocol Tag {
    var html: String { get }
}

extension CustomTags.SEO {
    fileprivate struct RawTag: Tag {
        var html: String
    }
    
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

extension CustomTags.SEO {
    fileprivate struct LinkedJSON {
        static let schema = "https://schema.org"
        
        let data: LinkedJSONData
        
        var html: String {
            get throws {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .formatted(CustomTags.SEO.formatter)
                encoder.outputFormatting = [.sortedKeys]
                let json = try encoder.encode(data)
                guard let jsonString = String(data: json, encoding: .utf8) else {
                    throw LinkedJSONDataEncodingError()
                }
                return """
                <script type="application/ld+json">
                \(jsonString.replacingOccurrences(of: "\\", with: ""))
                </script>
                """
            }
        }
    }
}

extension CustomTags.SEO {
    struct LinkedJSONDataEncodingError: Error {}
}

fileprivate protocol LinkedJSONData: Encodable {}

extension CustomTags.SEO.LinkedJSON {
    struct Person: LinkedJSONData {
        static let type = "Person"
        
        var firstName: String
        var lastName: String
        
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "@type"
            case firstName = "givenName"
            case lastName = "familyName"
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(CustomTags.SEO.LinkedJSON.schema, forKey: .context)
            try container.encode(Self.type, forKey: .type)
            try container.encode(firstName, forKey: .firstName)
            try container.encode(lastName, forKey: .lastName)
        }
    }
    
    struct WebSite: LinkedJSONData {
        static let type = "WebSite"
        var author: Person?
        var description: String?
        var headline: String?
        var name: String
        var url: String
        
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "@type"
            case author = "author"
            case description = "description"
            case headline = "headline"
            case name = "name"
            case url = "url"
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(CustomTags.SEO.LinkedJSON.schema, forKey: .context)
            try container.encode(Self.type, forKey: .type)
            
            try container.encodeIfPresent(author, forKey: .author)
            try container.encodeIfPresent(description, forKey: .description)
            try container.encodeIfPresent(headline, forKey: .headline)
            try container.encode(name, forKey: .name)
            try container.encode(url, forKey: .url)
        }
    }
    
    struct BlogPosting: LinkedJSONData {
        static let type = "BlogPosting"
        var name: String
        var author: Person?
        var datePublished: Date
        var description: String?
        var headline: String?
        var url: String
        var keywords: [String]?
        
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "@type"
            case name = "name"
            case author = "author"
            case datePublished = "datePublished"
            case description = "description"
            case headline = "headline"
            case mainEntityOfPage = "mainEntityOfPage"
            case url = "url"
            case keywords = "keywords"
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(CustomTags.SEO.LinkedJSON.schema, forKey: .context)
            try container.encode(Self.type, forKey: .type)
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(author, forKey: .author)
            try container.encode(datePublished, forKey: .datePublished)
            try container.encodeIfPresent(description, forKey: .description)
            try container.encodeIfPresent(headline, forKey: .headline)
            try container.encode(WebPage(id: url), forKey: .mainEntityOfPage)
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(keywords?.joined(separator: ","), forKey: .keywords)
        }
    }
    
    struct WebPage: LinkedJSONData {
        static let type = "WebPage"
        var id: String
        
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "@type"
            case id = "@id"
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(CustomTags.SEO.LinkedJSON.schema, forKey: .context)
            try container.encode(Self.type, forKey: .type)
            try container.encode(id, forKey: .id)
        }
    }
}
