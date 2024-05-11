import Stencil

extension CustomFilters {
    enum Append {
        static func makeExtension() -> Extension {
            let ext = Extension()
            ext.registerFilter("append") { value, arguments in
                guard let value = value as? String else { return value }
                
                let arguments = arguments.compactMap({ $0 as? String })
                
                guard !arguments.isEmpty else { return value }
                
                return "\(value)\(arguments.joined())"
            }
            return ext
        }
    }
}
