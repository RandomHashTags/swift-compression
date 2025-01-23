//
//  CompressionResult.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public struct CompressionResult<T : Sendable> : Sendable {
    public var data:T
    public var rootNode:CompressionTechnique.Huffman.Node?
    public var frequencyTable:[Int]?
    public var validBitsInLastByte:UInt8

    public init(
        data: T,
        rootNode: CompressionTechnique.Huffman.Node? = nil,
        frequencyTable: [Int]? = nil,
        validBitsInLastByte: UInt8 = 8
    ) {
        self.data = data
        self.rootNode = rootNode
        self.frequencyTable = frequencyTable
        self.validBitsInLastByte = validBitsInLastByte
    }
}