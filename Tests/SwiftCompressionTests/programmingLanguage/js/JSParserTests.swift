//
//  JSParserTests.swift
//
//
//  Created by Evan Anderson on 8/15/24.
//

import Testing
@testable import SwiftCompression

struct JSParserTests {
    @Test func parseJS() {
        // TODO: fix
        //let bro:JSBody = JSParser.parse("if(true){let bro=5;var yoink=true;for(var i=0;i<5;i++){console.log(\"bro\")}}")
        //print("MinificationJS;bro=\(bro)")
    }

    @Test func parseJSVar() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .var, "var bro=0;")
        #expect(bro == .declareVariables(type: .var, names: ["bro"], values: [.literal(value: "0")]))
    }
    @Test func parseJSVars1() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .var, "var bro1,bro2,bro3;")
        #expect(bro == .declareVariables(type: .var, names: ["bro1", "bro2", "bro3"], values: [
            .literal(value: ""),
            .literal(value: ""),
            .literal(value: "")
        ]))
    }
    @Test func parseJSVars2() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .var, "var bro1=0,bro2,bro3;")
        #expect(bro == .declareVariables(type: .var, names: ["bro1", "bro2", "bro3"], values: [
            .literal(value: "0"),
            .literal(value: ""),
            .literal(value: "")
        ]))
    }

    @Test func parseJSLet() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .let, "let bro=0;")
        #expect(bro == .declareVariables(type: .let, names: ["bro"], values: [.literal(value: "0")]))
    }
    @Test func parseJSLets1() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .let, "let bro1,bro2,bro3;")
        #expect(bro == .declareVariables(type: .let, names: ["bro1", "bro2", "bro3"], values: [
            .literal(value: ""),
            .literal(value: ""),
            .literal(value: "")
        ]))
    }
    @Test func parseJSLets2() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .let, "let bro1=0,bro2,bro3;")
        #expect(bro == .declareVariables(type: .let, names: ["bro1", "bro2", "bro3"], values: [
            .literal(value: "0"),
            .literal(value: ""),
            .literal(value: "")
        ]))
    }

    @Test func parseJSConst() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .const, "const bro=0;")
        #expect(bro == .declareVariables(type: .const, names: ["bro"], values: [.literal(value: "0")]))
    }
    @Test func parseJSConsts1() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .const, "const bro1,bro2,bro3;")
        #expect(bro == .declareVariables(type: .const, names: ["bro1", "bro2", "bro3"], values: [
            .literal(value: ""),
            .literal(value: ""),
            .literal(value: "")
        ]))
    }
    @Test func parseJSConsts2() {
        let bro:JSDeclaration = JSDeclaration.parseDeclareVariables(type: .const, "const bro1=0,bro2,bro3;")
        #expect(bro == .declareVariables(type: .const, names: ["bro1", "bro2", "bro3"], values: [
            .literal(value: "0"),
            .literal(value: ""),
            .literal(value: "")
        ]))
    }

    @Test func parseJSBranch() {
        let bro:JSDeclaration = JSDeclaration.parseBranch("if(true){}")
        #expect(bro == .branch(branch: JSBranch(condition: "true", body: JSBody.empty), else: []))
    }
    @Test func parseJSReturn() {
        let bro:JSDeclaration = JSDeclaration.parseReturn("return x;")
        #expect(bro == .return(value: .literal(value: "x;")))
    }
}

// MARK: Functions
extension JSParserTests {
    static let testFunction1ExpectedResult:JSDeclaration = .function(name: "lets_go_bro", parameters: ["ez", "clap"], body: JSBody.empty)
    static let testFunction2ExpectedResult:JSDeclaration = .function(name: "lets_go_bro", parameters: ["ez", "clap"], body: JSBody(declarations: [
        JSDeclaration.declareVariables(type: .const, names: ["um"], values: [JSDeclaration.literal(value: "1")])
    ]))

    @Test func parseJSFunction1() {
        let bro:JSDeclaration = JSDeclaration.parseFunction("function lets_go_bro(ez,clap){}")
        #expect(bro == Self.testFunction1ExpectedResult)
    }
    @Test func parseJSFunction2() {
        let bro:JSDeclaration = JSDeclaration.parseFunction("function lets_go_bro(ez,clap){const um=1;}")
        #expect(bro == Self.testFunction2ExpectedResult)
    }
}

// MARK: Renaming
extension JSParserTests {
    @Test func jsRenaming1() {
        var body:JSBody = JSBody(declarations: [
            .function(name: "big_bro", parameters: ["little", "small"], body: JSBody.empty),
            .function(name: "small_bro", parameters: [], body: JSBody(declarations: [
                .declareVariables(type: .const, names: ["down", "diggity"], values: [.literal(value: "1"), .literal(value: "2")]),
                .referenceFunction(variable: nil, name: "big_bro", parameters: ["down", "diggity"]),
                .declareVariables(type: .const, names: ["poggy_woggy"], values: [.literal(value: "1")])
            ])),
        ])
        let before:String = body.string
        body.rename()
        let after:String = body.string
        print("before.count=\(before.count);after.count=\(after.count);saved %=\(Double(after.count) / Double(before.count) * 100)")
    }
}

// MARK: Declaration strings
extension JSParserTests {
    @Test func jsStringFunction1() {
        #expect(Self.testFunction1ExpectedResult.string == "function lets_go_bro(ez,clap){}")
    }
    @Test func jsStringFunction2() {
        #expect(Self.testFunction2ExpectedResult.string == "function lets_go_bro(ez,clap){const um=1;}")
    }

    @Test func jsStringBranch1() {
        #expect(JSBranch(condition: "true", body: JSBody.empty).string == "if(true){}")
    }
}