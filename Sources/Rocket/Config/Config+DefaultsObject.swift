import Foundation
import PathKit

extension Config {
    struct Defaults {
        let path: Path
        let values: [String: Any]
    }
}

extension Config.Defaults {
    init?(from dict: [String: Any]) {
        guard let path = dict["path"] as? String,
              let values = dict["values"] as? [String: Any]
        else { return nil }
        self.path = Path.current + path
        self.values = values
    }
}
