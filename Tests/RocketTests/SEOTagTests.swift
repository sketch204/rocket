import XCTest
@testable import Rocket
import PathKit

final class SEOTagTests: XCTestCase {
    typealias SEO = CustomTags.SEO
    
    let config = Config()
    let context = Context()
    
    
    // MARK: General
    
    func test_doesNotGenerateTags_whenSEODataMissing() {
        let config = Config()
        let context = Context()
        
        let content = SEO.generateContent(with: config, context: context)
        
        XCTAssertEqual(content, "")
    }
    
    
    // MARK: Title
    
    func test_generatesTitleTags_whenTitleIsInSEOBlock() throws {
        let title = "Website Title"
        let config = Config(
            userProperties: [
                "seo": [
                    "title": title
                ]
            ]
        )
        
        let content = SEO.generateContent(with: config, context: context)
        let titleTag = "<title>\(title)</title>"
        let metaTitleTag = "<meta property=\"og:title\" content=\"\(title)\" />"
        
        XCTAssertTrue(content.contains(titleTag), "Title tag '\(titleTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(metaTitleTag), "Meta title tag '\(metaTitleTag)', missing from '\(content)'")
    }
    
    func test_generatesTitleTags_whenTitleIsAlsoInPageContext() throws {
        let title = "Website Title"
        let config = Config(
            userProperties: [
                "seo": [
                    "title": title
                ]
            ]
        )
        let context = Context(dictionary: [
            "title": title
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let titleTag = "<title>\(title)</title>"
        let metaTitleTag = "<meta property=\"og:title\" content=\"\(title)\" />"
        
        XCTAssertTrue(content.contains(titleTag), "Title tag '\(titleTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(metaTitleTag), "Meta title tag '\(metaTitleTag)', missing from '\(content)'")
    }
    
    func test_generatesSiteNameTags_whenTitleIsInSEOBlock() throws {
        let title = "Website Title"
        let config = Config(
            userProperties: [
                "seo": [
                    "title": title
                ]
            ]
        )
        
        let content = SEO.generateContent(with: config, context: context)
        let siteNameTag = "<meta property=\"og:site_name\" content=\"\(title)\" />"
        
        XCTAssertTrue(content.contains(siteNameTag), "Meta site name tag '\(siteNameTag)', missing from '\(content)'")
    }
    
    
    // MARK: Description
    
    func text_generatesDescriptionTags_whenDescriptionIsInSEOBlock() {
        let description = "description"
        let config = Config(
            userProperties: [
                "seo": [
                    "description": description
                ]
            ]
        )
        
        let content = SEO.generateContent(with: config, context: context)
        let metaDescriptionTag1 = "<meta property=\"og:description\" content=\"\(description)\" />"
        let metaDescriptionTag2 = "<meta name=\"description\" content=\"\(description)\" />"
        
        XCTAssertTrue(content.contains(metaDescriptionTag1), "Meta description tag 1 '\(metaDescriptionTag1)', missing from '\(content)'")
        XCTAssertTrue(content.contains(metaDescriptionTag2), "Meta description tag 2 '\(metaDescriptionTag2)', missing from '\(content)'")
    }
    
    func test_generatesDescriptionTags_whenDescriptionIsAlsoInPageContext() throws {
        let description = "description"
        let config = Config(
            userProperties: [
                "seo": [
                    "description": description
                ]
            ]
        )
        
        let context = Context(dictionary: [
            "description": description
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let metaDescriptionTag1 = "<meta property=\"og:description\" content=\"\(description)\" />"
        let metaDescriptionTag2 = "<meta name=\"description\" content=\"\(description)\" />"
        
        XCTAssertTrue(content.contains(metaDescriptionTag1), "Meta description tag 1 '\(metaDescriptionTag1)', missing from '\(content)'")
        XCTAssertTrue(content.contains(metaDescriptionTag2), "Meta description tag 2 '\(metaDescriptionTag2)', missing from '\(content)'")
    }
    
    
    // MARK: Author
    
    func test_generatesAuthorTags() {
        let author = "author"
        let config = Config(
            userProperties: [
                "seo": [
                    "author": author
                ]
            ]
        )
        
        let content = SEO.generateContent(with: config, context: context)
        let authorTag = "<meta name=\"author\" content=\"\(author)\" />"
        
        XCTAssertTrue(content.contains(authorTag), "Meta author tag '\(authorTag)', missing from '\(content)'")
    }
    
    func test_generatesAuthorTags_forProfilePage_fromSEOData() {
        let firstName = "first"
        let lastName = "last"
        let username = "user"
        let config = Config(
            userProperties: [
                "seo": [
                    "author": [
                        "firstName": firstName,
                        "lastName": lastName,
                        "username": username,
                    ]
                ]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "pageType": "profile",
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let firstNameTag = "<meta name=\"profile:first_name\" content=\"\(firstName)\" />"
        let lastNameTag = "<meta name=\"profile:last_name\" content=\"\(lastName)\" />"
        let usernameTag = "<meta name=\"profile:username\" content=\"\(username)\" />"
        let authorTag = "<meta name=\"author\" content=\"\(firstName) \(lastName)\" />"
        
        XCTAssertTrue(content.contains(firstNameTag), "Meta first name author tag '\(firstNameTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(lastNameTag), "Meta last name author tag '\(lastNameTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(usernameTag), "Meta username author tag '\(usernameTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(authorTag), "Meta author tag '\(authorTag)', missing from '\(content)'")
    }
    
    func test_generatesAuthorTags_forProfilePage_fromPageData() {
        let firstName = "first"
        let lastName = "last"
        let username = "user"
        let config = Config(
            userProperties: [
                "seo": [:]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "pageType": "profile",
                "author": [
                    "firstName": firstName,
                    "lastName": lastName,
                    "username": username,
                ]
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let firstNameTag = "<meta name=\"profile:first_name\" content=\"\(firstName)\" />"
        let lastNameTag = "<meta name=\"profile:last_name\" content=\"\(lastName)\" />"
        let usernameTag = "<meta name=\"profile:username\" content=\"\(username)\" />"
        let authorTag = "<meta name=\"author\" content=\"\(firstName) \(lastName)\" />"
        
        XCTAssertTrue(content.contains(firstNameTag), "Meta first name author tag '\(firstNameTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(lastNameTag), "Meta last name author tag '\(lastNameTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(usernameTag), "Meta username author tag '\(usernameTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(authorTag), "Meta author tag '\(authorTag)', missing from '\(content)'")
    }
    
    
    // MARK: Locale
    
    func test_generatesLocaleTags() {
        let locale = "en_CA"
        let config = Config(
            userProperties: [
                "seo": [
                    "locale": locale
                ]
            ]
        )
        
        let content = SEO.generateContent(with: config, context: context)
        let localeTag = "<meta property=\"og:locale\" content=\"\(locale)\" />"
        
        XCTAssertTrue(content.contains(localeTag), "Meta locale tag '\(localeTag)', missing from '\(content)'")
    }
    
    func test_generatesLocaleTags_whenLocaleUnspecified() {
        let locale = "en_US"
        let config = Config(
            userProperties: [
                "seo": [:]
            ]
        )
        
        let content = SEO.generateContent(with: config, context: context)
        let localeTag = "<meta property=\"og:locale\" content=\"\(locale)\" />"
        
        XCTAssertTrue(content.contains(localeTag), "Meta locale tag '\(localeTag)', missing from '\(content)'")
    }
    
    
    // MARK: Canonical URL
    
    func test_generatesCanonicalUrlTags() {
        let url = "https://example.com"
        let config = Config(
            userProperties: [
                "seo": [
                    "siteURL": url
                ]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "outputPath": Path()
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let linkTag = "<link rel=\"canonical\" href=\"\(url)\" />"
        let metaTag = "<meta property=\"og:url\" content=\"\(url)\" />"
        
        XCTAssertTrue(content.contains(linkTag), "Link tag '\(linkTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(metaTag), "Meta URL tag '\(metaTag)', missing from '\(content)'")
    }
    
    func test_generatesCanonicalUrlTags_whenOutputPathExists() {
        let siteUrl = "https://example.com"
        let path = "/some/path/to/page"
        let url = "\(siteUrl)\(path)"
        let config = Config(
            userProperties: [
                "seo": [
                    "siteURL": siteUrl
                ]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "outputPath": Path(path)
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let linkTag = "<link rel=\"canonical\" href=\"\(url)\" />"
        let metaTag = "<meta property=\"og:url\" content=\"\(url)\" />"
        
        XCTAssertTrue(content.contains(linkTag), "Link tag '\(linkTag)', missing from '\(content)'")
        XCTAssertTrue(content.contains(metaTag), "Meta URL tag '\(metaTag)', missing from '\(content)'")
    }
    
    
    // MARK: Generator
    
    func test_generatesGeneratorTag() {
        let config = Config(
            userProperties: [
                "seo": [:]
            ]
        )
        
        let content = SEO.generateContent(with: config, context: context)
        let generatorTag = "<meta name=\"generator\" content=\"Rocket\" />"
        
        XCTAssertTrue(content.contains(generatorTag), "Generator tag '\(generatorTag)', missing from '\(content)'")
    }
    
    
    // MARK: Type
    
    func test_generatesTypeTag_whenNormalPage() {
        let type = "website"
        let config = Config(
            userProperties: [
                "seo": [:]
            ]
        )
        
        let content = SEO.generateContent(with: config, context: context)
        let typeTag = "<meta property=\"og:type\" content=\"\(type)\" />"
        
        XCTAssertTrue(content.contains(typeTag), "Type tag '\(typeTag)', missing from '\(content)'")
    }
    
    func test_generatesTypeTag_whenPostPage() {
        let type = "article"
        let postsPath = Path("posts")
        let config = Config(
            postsPath: postsPath,
            userProperties: [
                "seo": [:]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "isPost": true
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let typeTag = "<meta property=\"og:type\" content=\"\(type)\" />"
        
        XCTAssertTrue(content.contains(typeTag), "Type tag '\(typeTag)', missing from '\(content)'")
    }
    
    func test_generatesTypeTag_whenOverrideToPostPage() {
        let type = "article"
        let config = Config(
            userProperties: [
                "seo": [:]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "pageType": type
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let typeTag = "<meta property=\"og:type\" content=\"\(type)\" />"
        
        XCTAssertTrue(content.contains(typeTag), "Type tag '\(typeTag)', missing from '\(content)'")
    }
    
    func test_generatesTypeTag_whenOverrideToProfilePage() {
        let type = "profile"
        let config = Config(
            userProperties: [
                "seo": [:]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "pageType": type
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let typeTag = "<meta property=\"og:type\" content=\"\(type)\" />"
        
        XCTAssertTrue(content.contains(typeTag), "Type tag '\(typeTag)', missing from '\(content)'")
    }
    
    
    // MARK: Article Date
    
    func test_generatesArticleDateTags() {
        let date = DateComponents(
            calendar: .current,
            year: 2024,
            month: 06,
            day: 03
        ).date!
        let config = Config(
            userProperties: [
                "seo": [:]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "pageType": "article",
                "date": date
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let dateTag = "<meta property=\"article:published_time\" content=\"2024-06-03T00:00:00-04:00\" />"
        
        XCTAssertTrue(content.contains(dateTag), "Date tag '\(dateTag)', missing from '\(content)'")
    }
    
    func test_generatesArticleTagsTags() {
        let tag1 = "tag1"
        let tag2 = "tag2"
        let config = Config(
            userProperties: [
                "seo": [:]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "tags": [tag1, tag2]
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let tag1Html = "<meta property=\"article:tag\" content=\"\(tag1)\" />"
        let tag2Html = "<meta property=\"article:tag\" content=\"\(tag2)\" />"
        
        XCTAssertTrue(content.contains(tag1Html), "Tag '\(tag1Html)', missing from '\(content)'")
        XCTAssertTrue(content.contains(tag2Html), "Tag '\(tag2Html)', missing from '\(content)'")
    }
    
    func test_generatesLinkedJsonTags() {
        let url = "https://example.com"
        let title = "Website Title"
        let config = Config(
            userProperties: [
                "seo": [
                    "title": title,
                    "siteURL": url,
                ]
            ]
        )
        let context = Context(dictionary: [
            "page": [
                "outputPath": Path("path/to/file"),
            ]
        ])
        
        let content = SEO.generateContent(with: config, context: context)
        let linkedJsonTag = """
        <script type="application/ld+json">
        {"@context":"https://schema.org","@type":"WebSite","name":"Website Title","url":"https://example.compath/to/file"}
        </script>
        """
        
        XCTAssertTrue(content.contains(linkedJsonTag), "Linked JSON tag '\(linkedJsonTag)', missing from '\(content)'")
    }
}
