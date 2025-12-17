

import UIKit
import SwiftyJSON

public let CacheService = _Cache.shared

public class _Cache: NSObject {
    
    static let shared = _Cache()
    private let userDefaults = UserDefaults.standard
    private var userSession: UserSessionModel?
    
    public var currentSession: UserSessionModel? {
        set {
            self.userSession = newValue
            if newValue == nil {
                userDefaults.removeObject(forKey: USER_DEFAULT_KEY.HF_USER_SESSION)
            } else {
                let jsonString = newValue?.toDictionary() ?? [:]
                userDefaults.set(jsonString, forKey: USER_DEFAULT_KEY.HF_USER_SESSION)
            }
        }
        get {
            if userSession != nil {
                return userSession
            }
            let data = userDefaults.object(forKey: USER_DEFAULT_KEY.HF_USER_SESSION) ?? [:]
            userSession = UserSessionModel(json: JSON(data))
            return userSession
        }
    }
    
    public var hasLogin: Bool {
        get{
            return currentSession != nil
        }
    }

    func removeAllCache() {
        userDefaults.removeObject(forKey: USER_DEFAULT_KEY.HF_TOKEN_USER)
        userDefaults.removeObject(forKey: USER_DEFAULT_KEY.HF_USER_SESSION)
        userDefaults.removeObject(forKey: USER_DEFAULT_KEY.HF_TOKEN_USER)
    }
}
