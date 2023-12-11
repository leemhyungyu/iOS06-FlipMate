//
//  DefaultGoogleAuthRepository.swift
//  FlipMate
//
//  Created by 신민규 on 11/23/23.
//

import Foundation

final class DefaultAuthenticationRepository: AuthenticationRepository {
    func googleLogin(with accessToken: String) async throws -> User {
        let requestDTO = GoogleAuthRequestDTO(accessToken: accessToken)
        let endpoint = GoogleAuthEndpoints.enterGoogleLogin(requestDTO)
        let responseDTO = try await provider.request(with: endpoint)
        
        return User(isMember: responseDTO.isMember, accessToken: responseDTO.accessToken)
    }
    
    private let provider: Providable
    
    init(provider: Providable) {
        self.provider = provider
    }
}