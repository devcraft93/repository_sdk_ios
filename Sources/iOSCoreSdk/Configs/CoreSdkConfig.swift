//
//  File.swift
//  
//
//  Created by Nguyen's Mac on 10/01/2024.
//

import Foundation

public final class CoreSdkConfig {
    /// SDk singleton
    public static let shared = CoreSdkConfig()
    
    var environment: CoreSdkEnvironment?
    
    private init() {}
    
    public func configure(environment: CoreSdkEnvironment) {
        self.environment = environment
    }
    
}
