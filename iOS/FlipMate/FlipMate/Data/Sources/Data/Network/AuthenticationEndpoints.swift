//
//  GoogleLoginEndpoints.swift
//  FlipMate
//
//  Created by 신민규 on 11/23/23.
//

import Foundation
import Network

struct AuthenticationEndpoints {
    static func enterGoogleLogin(_ dto: GoogleAuthRequestDTO) -> EndPoint<AuthResponseDTO> {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(dto)
        return EndPoint(baseURL: BaseURL.flipmateDomain, path: Paths.googleApp, method: .post, data: data)
    }
    
    static func enterAppleLogin(_ dto: AppleAuthRequestDTO) -> EndPoint<AuthResponseDTO> {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(dto)
        return EndPoint(baseURL: BaseURL.flipmateDomain, path: Paths.appleApp, method: .post, data: data)
    }
    
    static func withdraw() -> EndPoint<StatusResponseDTO> {
        return EndPoint(
            baseURL: BaseURL.flipmateDomain,
            path: Paths.auth,
            method: .delete)
    }
}
