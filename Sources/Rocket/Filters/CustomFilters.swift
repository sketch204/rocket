import Stencil

enum CustomFilters {
    static func extensions(config: Config) -> [Extension] {
        [
            SiteURL.makeExtension(with : config),
            Append.makeExtension(),
            Prepend.makeExtension(),
            Date.makeExtension()
        ]
    }
}
