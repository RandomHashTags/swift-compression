//
//  CompressionResult.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

struct CompressionResult {
    let data:Data
    let frequencyTable:[String:String]?

    init(data: Data, frequencyTable: [String:String]? = nil) {
        self.data = data
        self.frequencyTable = frequencyTable
    }
}