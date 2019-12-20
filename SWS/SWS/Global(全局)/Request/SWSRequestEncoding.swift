//
//  SWSRequestEncoding.swift
//  CloudOffice
//
//  Created by 刘健 on 2017/1/4.
//  Copyright © 2017年 115.com. All rights reserved.
//

import Foundation
//import Alamofire

struct FormData {
    
    var data: Data? {
        if let rawData = self.rawData {
            return rawData
        } else if let filePath = self.filePath {
            return try? Data(contentsOf: URL(fileURLWithPath: filePath))
        }
        return nil
    }
    
    let key: String
    var mimeType = "application/octet-stream"
    var fileName = "file"
    
    let rawData: Data?
    let filePath: String?
    
    init(data: Data, key: String) {
        self.rawData = data
        self.filePath = nil
        self.key = key
    }
    
    init(filePath: String, key: String) {
        self.filePath = filePath
        self.rawData = nil
        self.key = key
    }
    
}

public struct SWSRequestEncoding: ParameterEncoding {
    
    let encrypt: Bool
    let multipartFormData: [FormData]
    var customContentType: String?
    var timeOutInSeconds: Int?
    
    init(encrypt: Bool, multipartFormData: [FormData] = []) {
        self.encrypt = encrypt
        self.multipartFormData = multipartFormData
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        if let timeOutInSeconds = timeOutInSeconds {
            urlRequest.timeoutInterval = TimeInterval(timeOutInSeconds)
        }
        guard let parameters = parameters else { return urlRequest }
        
        if let method = HTTPMethod(rawValue: urlRequest.httpMethod ?? "GET"), encodesParametersInURL(with: method) {
            guard let url = urlRequest.url else {
                throw AFError.parameterEncodingFailed(reason: .missingURL)
            }
            
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                urlRequest.url = urlComponents.url
            }
        } else {
            var httpBodyData: Data? = nil
            if multipartFormData.count == 0 {
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
                }
                httpBodyData = getJSONFromDictionary(parameters)//query(parameters).data(using: .utf8, allowLossyConversion: false)
            } else {
                let boundary = "0xKhTmLbOuNdArY"
                var data = Data()
                for (key, value) in parameters {
                    let thisFieldString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)"
                    if let tempData = thisFieldString.data(using: .utf8, allowLossyConversion: false) {
                        data.append(tempData)
                    }
                    if let tempData = "\r\n".data(using: .utf8, allowLossyConversion: false) {
                        data.append(tempData)
                    }
                }
                multipartFormData.forEach { formData in
                    let thisFieldString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(formData.key)\"; filename=\"\(formData.fileName)\"\r\nContent-Type: \(formData.mimeType)\r\nContent-Transfer-Encoding: binary\r\n\r\n"
                    if let tempData = thisFieldString.data(using: .utf8, allowLossyConversion: false) {
                        data.append(tempData)
                    }
                    if let tempData = formData.data {
                        data.append(tempData)
                    }
                    if let tempData = "\r\n".data(using: .utf8, allowLossyConversion: false) {
                        data.append(tempData)
                    }
                }
                if let tempData = "--\(boundary)--\r\n".data(using: .utf8, allowLossyConversion: false) {
                    data.append(tempData)
                }
                
                if let contentType = customContentType {
                    urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
                } else {
                    if let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)) {
                        let string = String(charset)
                        urlRequest.setValue("multipart/form-data; charset=\(string); boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    }
                }
                urlRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
                
                httpBodyData = data
            }
//            if let data = httpBodyData, encrypt {
//                if let encryptData = EncryptKeygen.ec115EncryptRequest(data) {
//                    httpBodyData = encryptData
//                    urlRequest.setValue(String(format: "%lu", encryptData.count), forHTTPHeaderField: "Content-Length")
//                } else {
//                    fatalError("加密失败")
//                }
//            }
            urlRequest.httpBody = httpBodyData
        }
        
        return urlRequest
    }
    
    /// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
    ///
    /// - parameter key:   The key of the query component.
    /// - parameter value: The value of the query component.
    ///
    /// - returns: The percent-escaped, URL encoded query string components.
    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    ///
    /// - parameter string: The string to be percent-escaped.
    ///
    /// - returns: The percent-escaped string.
    public func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
        //  info, please refer to:
        //
        //      - https://github.com/Alamofire/Alamofire/issues/206
        //
        //==========================================================================================================
        
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                
                let substring = string.substring(with: range)
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
                
                index = endIndex
            }
        }
        
        return escaped
    }
    
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
//    private func queryToJson(_ parameters: [String: Any]) -> String {
//       let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
////        var components: [(String, String)] = []
////
////        for key in parameters.keys.sorted(by: <) {
////            let value = parameters[key]!
////            components += queryComponents(fromKey: key, value: value)
////        }
////
////        return components.map { "\($0)=\($1)" }.joined(separator: "&")
//    }
    
    private func encodesParametersInURL(with method: HTTPMethod) -> Bool {
        switch method {
        case .get, .head, .delete:
            return true
        default:
            return false
        }
    }
}


