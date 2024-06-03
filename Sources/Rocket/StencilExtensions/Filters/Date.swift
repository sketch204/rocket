import Foundation
import Stencil

extension CustomFilters {
    enum Date {
        static func makeExtension() -> Extension {
            let ext = Extension()
            
            let dateFormatter = DateFormatter()
            let defaultDateFormat = "yyyy-MM-dd HH:mm:ss"
            
            ext.registerFilter("date") { value, arguments in
                guard let date = value as? Foundation.Date else { return value }
                
                if let format = arguments.compactMap({ $0 as? String }).first {
                    dateFormatter.dateFormat = format
                } else {
                    dateFormatter.dateFormat = defaultDateFormat
                }
                
                return dateFormatter.string(from: date)
            }
            
            return ext
        }
    }
}
