//
//  ThngReader.swift
//  EvrythngiOS
//
//  Created by JD Castro on 22/05/2017.
//  Copyright © 2017 ImFree. All rights reserved.
//

import UIKit
import Moya
import MoyaSugar
import Moya_SwiftyJSONMapper

public class ThngReader: EvrythngNetworkExecutableProtocol {
    
    public var apiKey: String?
    
    private var thngId: String?
    
    private init() {
        
    }
    
    public required init(thngId: String) {
        self.thngId = thngId
    }
    
    public func getDefaultProvider() -> EvrythngMoyaProvider<EvrythngNetworkService> {
        let provider = EvrythngMoyaProvider<EvrythngNetworkService>()
        provider.apiKey = self.apiKey
        return provider
    }
    
    public func execute(completionHandler: @escaping (Thng? , Swift.Error?) -> Void) {
        
        if let thngId = self.thngId {
            
            let readThngRequest = EvrythngNetworkService.readThng(apiKey: self.apiKey, thngId: thngId)
            self.getDefaultProvider().request(readThngRequest) { result in
                switch result {
                case let .success(moyaResponse):
                    let data = moyaResponse.data
                    let statusCode = moyaResponse.statusCode
                    let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    
                    if(Evrythng.DEBUGGING_ENABLED) {
                        print("Data: \(String(describing: datastring)) Status Code: \(statusCode)")
                    }
                    
                    if(200..<300 ~= statusCode) {
                        do {
                            let thng = try moyaResponse.map(to: Thng.self)
                            if(Evrythng.DEBUGGING_ENABLED) {
                                print("SwiftyJSON: \(thng)")
                            }
                            completionHandler(thng, nil)
                        } catch {
                            print(error)
                            completionHandler(nil, error)
                        }
                    } else {
                        do {
                            let err = try moyaResponse.map(to: EvrythngNetworkErrorResponse.self)
                            if(Evrythng.DEBUGGING_ENABLED) {
                                print("EvrythngNetworkErrorResponse: \(String(describing: err.jsonData?.rawString()))")
                            }
                            completionHandler(nil, EvrythngNetworkError.ResponseError(response: err))
                        } catch {
                            print(error)
                            completionHandler(nil, error)
                        }
                    }
                    
                case let .failure(error):
                    print("Error: \(error)")
                    // this means there was a network failure - either the request
                    // wasn't sent (connectivity), or no response was received (server
                    // timed out).  If the server responds with a 4xx or 5xx error, that
                    // will be sent as a ".success"-ful response.
                    completionHandler(nil, error)
                    break
                }
            }
        }
    }
}
