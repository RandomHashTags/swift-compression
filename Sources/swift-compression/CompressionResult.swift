//
//  CompressionResult.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public struct CompressionResult {
    public var data:[UInt8]
    public var frequencyTable:[String:String]?

    public init(data: [UInt8], frequencyTable: [String:String]? = nil) {
        self.data = data
        self.frequencyTable = frequencyTable
    }
}