import Foundation
import PathKit
import TOMLKit

// MARK: Decoding Key

struct StringCodingKey: CodingKey, Equatable {
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}


// MARK: Dictionary Decoding

extension Dictionary where Key == String, Value == Any {
    init(from decoder: any Decoder) throws {
        try self.init(
            from: decoder.container(keyedBy: StringCodingKey.self)
        )
    }

    init(from container: KeyedDecodingContainer<StringCodingKey>) throws{
        var output = [String: Any]()
        
        for key in container.allKeys {
            output[key.stringValue] = try container.supportedValue(for: key)
        }
        
        self = output
    }
}

extension Array where Element == Any {
    init(from container: UnkeyedDecodingContainer) throws {
        var container = container
        
        var output = [Any]()
        
        while !container.isAtEnd {
            try output.append(container.supportedValue())
        }
        
        self = output
    }
}

extension UnkeyedDecodingContainer {
    fileprivate mutating func supportedValue() throws -> Any {
        if let number = try? self.decode(Double.self) {
            return number
        }
        else if let objectContainer = try? self.nestedContainer(keyedBy: StringCodingKey.self) {
            return try Dictionary(from: objectContainer)
        }
        else if let arrayContainer = try? self.nestedUnkeyedContainer() {
            return try Array(from: arrayContainer)
        }
        else if let string = try? self.decode(String.self) {
            return string
        }
        else if let date = try? self.decode(Date.self) {
            return date
        }
        else {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unsupported data type encountered.")
        }
    }
}

extension KeyedDecodingContainer where K == StringCodingKey {
    fileprivate func supportedValue(for key: StringCodingKey) throws -> Any {
        if let date = try? self.decode(Date.self, forKey: key) {
            return date
        }
        else if let number = try? self.decode(Double.self, forKey: key) {
            return number
        }
        else if let objectContainer = try? self.nestedContainer(keyedBy: StringCodingKey.self, forKey: key) {
            return try Dictionary(from: objectContainer)
        }
        else if let arrayContainer = try? self.nestedUnkeyedContainer(forKey: key) {
            return try Array(from: arrayContainer)
        }
        else if let string = try? self.decode(String.self, forKey: key) {
            return string
        }
        else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unsupported data type encountered.")
        }
    }
}


// MARK: Path Decoding

extension Path {
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        switch self.url.pathExtension {
        case "toml":
            let decoder = TOMLDecoder()
            return try decoder.decode(type, from: self.read())
            
        case "json":
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: Data(contentsOf: self.url))
            
        default:
            throw UnsupportedConfigurationFileFormat(format: self.url.pathExtension)
        }
    }
}
