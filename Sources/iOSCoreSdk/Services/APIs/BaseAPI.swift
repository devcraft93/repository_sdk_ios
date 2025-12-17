
import UIKit
import PromiseKit
import SwiftyJSON
import Moya

public enum APIResult {
    case success(data: Any?)
    case error(error: Error)
}


let STATUS_SUCCESS_CODE = [200, 201, 204, 304]

//MARK: Support Functions
open class BaseAPI: NSObject  {
    
    public static func _request<OBJECT:BaseModel,T>(target: T,
                           autoValidateResult: Bool = true) -> Promise<OBJECT> where T : (TargetType){
        return Promise<OBJECT>(resolver: { (resolver) in
            let provider = MoyaProvider<T>()
            provider.request(target, completion: { (result) in
                switch result {
                case let .success(value):
                    let jsonData = JSON(value.data)
                    let object = OBJECT(json: jsonData)
                    
                    print("\n\n==>[API] \(String(describing: value.request?.url)) RESPONSES:\n \(jsonData)")
                    
                    guard autoValidateResult else {
                        object.data = jsonData
                        return resolver.fulfill(object)
                    }
                    if jsonData["success"].boolValue {
                        return resolver.fulfill(object)
                        
                    }else {
                        //TODO: filter error
                        let errorCode = jsonData["error"]["error_code"].intValue
                        let errorType = APIError.ErrorType(rawValue: errorCode) ?? APIError.ErrorType.unknown
                        return resolver.reject(APIError.defineError(errorType: errorType))
                    }
                case let .failure(error as NSError):
                    if let errorType  = APIError.ErrorType(rawValue: error.code) {
                        let err = APIError.defineError(errorType: errorType)
                        return resolver.reject(err)
                    }
                    return resolver.reject(error)
                }
            })
        })
    }
    
    public static func request<T>(
        target: T,
        autoValidateResult: Bool = true,
        autoLogoutInvalidAuthen:Bool = true,
        refreshAccessTokenTarget: TargetType? = nil
    ) -> Promise<Data>  where T : (TargetType)
    {
        let dateStart = Date().timeIntervalSince1970
        return Promise<Data>(resolver: { (resolver) in
            #if DEBUG
            print("\n\n==>[API][\(target.method.rawValue)] \(target.baseURL.absoluteString + target.path) REQUEST:\n \(target.task)")
            #endif
            let provider = MoyaProvider<T>(refreshAccessTokenTarget: refreshAccessTokenTarget)
            provider.request(target, completion: { (result) in
                #if DEBUG
                   let dateEnd = Date().timeIntervalSince1970
                   print("Server time:\(dateEnd - dateStart)")
                #endif
                switch result {
                case let .success(value):
                    let jsonData = JSON(value.data)
                    #if DEBUG
                       print("\n\n==>[API] \(value.request?.url?.absoluteString ?? "") RESPONSES:[\(value.statusCode)]\n \(jsonData)")
                    #endif
                    guard autoValidateResult else {
                        return resolver.fulfill(value.data)
                    }
                    if STATUS_SUCCESS_CODE.contains(value.statusCode) {
                        return resolver.fulfill(value.data)
                        
                    } else {
                        //TODO: filter error
                        //let errorType = APIError.ErrorType(rawValue: value.statusCode) ?? APIError.ErrorType.unknown
                        
                        let message = jsonData["message"].string
                        let error = NSError(domain: E(message),
                                         code: value.statusCode,
                                         userInfo: nil)
                        
                        // Force logout if need
                        if autoLogoutInvalidAuthen {
                            forceLogoutIfNeed(error: error)
                        }
 
                        return resolver.reject(error)
                    }
                case let .failure(error as NSError):
                    // Force logout if need
                    if autoLogoutInvalidAuthen {
                        forceLogoutIfNeed(error: error)
                    }
                    if let errorType  = APIError.ErrorType(rawValue: error.code) {
                        let err = APIError.defineError(errorType: errorType)
                        
                        return resolver.reject(err)
                    }
                    return resolver.reject(error)
                }
            })
        })
        
        func forceLogoutIfNeed(error: NSError)  {
            let errorType = APIError.ErrorType(rawValue: error.code)
            if errorType == APIError.ErrorType.invalidAuthen || errorType == APIError.ErrorType.tokenExpired {
                NotificationCenter.default.post(
                    name: NSNotification.Name.shouldForcelogoutApp,
                    object: nil,
                    userInfo: [:]
                )
            }
        }
    }
}
