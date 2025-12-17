//
//  File.swift
//  
//
//  Created by Nguyen's Mac on 09/01/2024.
//

import Moya
import Foundation
import SwiftyJSON
import PromiseKit

extension MoyaProvider {
    
    public convenience init(
        plugins: [PluginType] = [],
        manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
        refreshAccessTokenTarget: TargetType? = nil
    ){
        if let target = refreshAccessTokenTarget {
            self.init(
                requestClosure: MoyaProvider.endpointResolver(refreshAccessTokenTarget: target),
                manager: manager,
                plugins: plugins
            )
        } else {
            self.init(
                requestClosure: MoyaProvider.defaultRequestMapping,
                manager: manager,
                plugins: plugins
            )
        }
    }
    
    static func endpointResolver<T>(refreshAccessTokenTarget: T) -> MoyaProvider<Target>.RequestClosure where T : (TargetType){
        return { (endpoint, closure) in
            //Getting the original request
            let request = try! endpoint.urlRequest()
            
            if (CacheService.currentSession?.hasValidToken == true) {
                // Token is valid, so just resume the original request
                closure(.success(request))
                return
            }
            
            #if DEBUG
                print("Token expired -> Refresh token....\n =>Current access token:\(CacheService.currentSession?.accessToken ?? "");\n ==>Refresh token:\(CacheService.currentSession?.refreshToken ?? "")")
            #endif
            
            let authenticationProvider = MoyaProvider<T>()

            //Do a request to refresh the authtoken based on refreshToken
            authenticationProvider.request(refreshAccessTokenTarget) { result in
                switch result {
                case .success(let response):
                    let jsonData = JSON(response.data)
                    let accessToken = jsonData["accessToken"].string
                    let refreshToken = jsonData["refreshToken"].string
                    let userSession = UserSessionModel(
                        accessToken: accessToken,
                        refreshToken: refreshToken ?? CacheService.currentSession?.accessToken,
                        tokenType: "",
                        userId: ""
                    )
                    CacheService.currentSession = userSession
                    
                    closure(.success(request))
                    
                    #if DEBUG
                        print("==>New token:\(jsonData)")
                    #endif
                    // closure(.success(request)) // This line will "resume" the actual request, and then you can use AccessTokenPlugin to set the Authentication header
                case .failure(let error):
                    #if DEBUG
                        print("==>Refresh token failed:\(error)")
                    #endif
                    closure(.failure(error)) //something went terrible wrong! Request will not be performed
                }
            }
        }
    }
}
