//
//  CompressionResult.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public struct CompressionResult<T> {
    public var data:T
    public var frequencyTable:[String:String]?

    public init(data: T, frequencyTable: [String:String]? = nil) {
        self.data = data
        self.frequencyTable = frequencyTable
    }
}