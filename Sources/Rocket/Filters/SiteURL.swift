import Stencil

enum SiteURL {
    static func makeExtension(with config: Config) -> Extension {
        let ext = Extension()
        ext.registerFilter("site_url") { value in
            guard var value = value as? String else { return value }
            
            if value.hasPrefix("/") {
                value.removeFirst()
            }
            
            return "\(config.baseURL)/\(value)"
        }
        return ext
    }
}
