import Foundation
import TOMLKit


// MARK: Decoding Key

public struct StringCodingKey: CodingKey, Equatable {
    public var stringValue: String
    
    public init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public var intValue: Int? { nil }
    public init?(intValue: Int) { nil }
}


// MARK: Dictionary Decoding

extension Dictionary where Key == String, Value == Any {
    public init(from decoder: any Decoder) throws {
        try self.init(
            from: decoder.container(keyedBy: StringCodingKey.self)
        )
    }

    public init(from container: KeyedDecodingContainer<StringCodingKey>) throws{
        var output = [String: Any]()
        
        for key in container.allKeys {
            output[key.stringValue] = try container.supportedValue(for: key)
        }
        
        self = output
    }
}

extension Array where Element == Any {
    public init(from container: UnkeyedDecodingContainer) throws {
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
        if let tomlDate = try? self.decode(TOMLDate.self) {
            if let date = tomlDate.date {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unsupported date type encountered")
            }
        }
        else if let bool = try? self.decode(Bool.self) {
            return bool
        }
        else if let number = try? self.decode(Double.self) {
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
        else {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unsupported data type encountered.")
        }
    }
}

extension KeyedDecodingContainer where K == StringCodingKey {
    fileprivate func supportedValue(for key: StringCodingKey) throws -> Any {
        if let tomlDate = try? self.decode(TOMLDate.self, forKey: key) {
            if let date = tomlDate.date {
                return date
            } else {
                throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unsupported date type encountered")
            }
        }
        else if let bool = try? self.decode(Bool.self, forKey: key) {
            return bool
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
