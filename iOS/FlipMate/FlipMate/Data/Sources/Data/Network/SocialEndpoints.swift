//
//  SocialEndpoints.swift
//  FlipMate
//
//  Created by 임현규 on 2023/11/30.
//

import Foundation
import Combine
import Network

struct SocialEndpoints {
    static func getMyFreinds(date: Date) -> EndPoint<[FriendsResponseDTO]> {
        return EndPoint(
            baseURL: BaseURL.flipmateDomain,
            path: Paths.friend + "?datetime=\(date.dateToString(format: .yyyyMMddTHHmmSS))&timezone=\(date.dateToString(format: .ZZZZZ))",
            method: .get)
        
    }
    
    static func fetchMyFriend(date: Date) -> EndPoint<[FriendsResponseDTO]> {
        return EndPoint(
            baseURL: BaseURL.flipmateDomain,
            path: Paths.friend + "?datetime=\(date.dateToString(format: .yyyyMMddTHHmmSS))&timezone=\(date.dateToString(format: .ZZZZZ))",
            method: .get)
    }
}
