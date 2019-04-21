//
//  MoyaResponse+Utility.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import Moya

protocol LHReference {
    static var resourceName: String { get set }
    //var refNames: String { get set }
    //var refName: String { get set }
}

//extension Moya.Response {
//    func mapNSArray() throws -> NSArray {
//        let any = try self.mapJSON()
//        guard let array = any as? NSArray else {
//            throw MoyaError.jsonMapping(self)
//        }
//        return array
//    }
//    
//    func mapModel<T: Codable>(_ type: T.Type) throws -> T where T: LHReference {
//        
//        print(String.init(data: data, encoding: .utf8) ?? "")
//        
//        let result = try self.mapJSON()
//        
//        if let resultDict = result as? [String: Any], let resource = resultDict[T.resourceName] as? [String: Any] {
//            if let dataJson = jsonDict["data"], !(dataJson is NSNull) {
//                let jsonData = try! JSONSerialization.data(withJSONObject: dataJson, options: [])
//                do {
//                    return try JSONDecoder().decode(type, from: jsonData)
//                }catch{
//                    throw MoyaError.jsonMapping(self)
//                }
//            } else if let errorCode = jsonDict["returnCode"] as? Int, let error = PokerError.error(code: errorCode) {
//                throw error
//            }
//        }
//        
//        throw MoyaError.jsonMapping(self)
//    }
//}
