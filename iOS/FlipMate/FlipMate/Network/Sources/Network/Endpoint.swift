//
//  EndPoint.swift
//  
//
//  Created by 권승용 on 5/16/24.
//

import Core
import Foundation

public typealias RequestResponseable = Responsable & Requestable

public struct EndPoint<R: Decodable>: RequestResponseable {
    public typealias Response = R
    
    public var baseURL: String
    public var path: String
    public var method: HTTPMethod
    public var data: Data?
    public var headers: [HTTPHeader]?
    
    public init(baseURL: String, path: String, method: HTTPMethod, data: Data? = nil, headers: [HTTPHeader]? = nil) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.data = data
        self.headers = headers
    }
    
    public func makeURLRequest(with token: String?) throws -> URLRequest {
        let url = try makeURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = data
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        headers?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.field)}
        return urlRequest
    }
    
    private func makeURL() throws -> URL {
        let fullPath = "\(baseURL)\(path)"
        guard let components = URLComponents(string: fullPath) else { throw NetworkError.invalidURLComponents }
        
        guard let url = components.url else { throw NetworkError.invalidURLComponents }
        return url
    }
}
