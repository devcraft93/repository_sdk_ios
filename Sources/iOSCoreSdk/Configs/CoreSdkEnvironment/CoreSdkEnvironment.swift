//
//  File.swift
//  
//
//  Created by Nguyen's Mac on 10/01/2024.
//

import Foundation

public struct CoreSdkEnvironment {
    let baseURL: URL
    let environmentName: String
    
    public init(baseURL: URL, environmentName: String) {
        self.baseURL = baseURL
        self.environmentName = environmentName
    }
}
