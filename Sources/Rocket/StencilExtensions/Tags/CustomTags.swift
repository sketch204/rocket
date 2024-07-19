import Stencil

enum CustomTags {
    static func extensions(config: Config) -> [Extension] {
        [
            SEO.makeExtension(with: config),
            TableOfContents.makeExtension(with: config),
        ]
    }
}
