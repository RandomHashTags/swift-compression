//
//  CompressionResult.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public struct CompressionResult<T> {
    public var data:T
    public var rootNode:CompressionTechnique.Huffman.Node?
    public var frequencyTable:[Int]?

    public init(
        data: T,
        rootNode: CompressionTechnique.Huffman.Node? = nil,
        frequencyTable: [Int]? = nil
    ) {
        self.data = data
        self.rootNode = rootNode
        self.frequencyTable = frequencyTable
    }
}