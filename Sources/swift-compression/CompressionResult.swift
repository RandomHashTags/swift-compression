//
//  CompressionResult.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

public struct CompressionResult {
    public let data:Data
    public let frequencyTable:[String:String]?

    public init(data: Data, frequencyTable: [String:String]? = nil) {
        self.data = data
        self.frequencyTable = frequencyTable
    }
}