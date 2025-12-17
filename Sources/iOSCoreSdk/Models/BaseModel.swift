
import UIKit
import SwiftyJSON

open class BaseModel: NSObject {
    var data: JSON?

    public  override init() {
        super.init()
    }
    
    public required init(json: JSON) {
         super.init()
     }

    public func mapList<T:BaseModel>(jsons: JSON) ->[T] {
         let result:[T] = jsons.array?.map({ (json) -> T in
             return T(json: json)
             
         }) ?? []
         
         return result
     }
     

}
