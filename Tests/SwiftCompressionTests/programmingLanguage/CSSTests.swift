//
//  CSSTests.swift
//
//
//  Created by Evan Anderson on 1/22/25.
//

#if compiler(>=6.0)

import Testing
@testable import SwiftCompression

// MARK: CSSTests
struct CSSTests {
}

// MARK: CSSMinifyTests
struct CSSMinifyTests {
    private func minify(_ string: String) -> String {
        return String(decoding: CompressionTechnique.css.minify(data: [UInt8](string.utf8), reserveCapacity: 0), as: UTF8.self)
    }
    @Test func minifyCSSNative() {
        #expect(minify("""
        * {
            box-sizing: border-box;
        }
        """) == "*{box-sizing:border-box;}")
    }

    @Test func minifyCSSCommaSeparatedInputs() {
        #expect(minify("""
        input[type=email], input[type=password], input[type=text], input[type=number], input[type=date], input[type=time] {
            border: 1px solid #ccc;
            border-radius: 3px;
        }
        """) == "input[type=email],input[type=password],input[type=text],input[type=number],input[type=date],input[type=time]{border:1px solid #ccc;border-radius:3px;}")
    }

    @Test func minifyCSSNestedClass() {
        #expect(minify("""
        div#notification_area .notification_popup .notification_popup_content {
        }
        """) == "div#notification_area .notification_popup .notification_popup_content{}")
    }

    @Test func minifyCSSComment() {
        #expect(minify("""
        div#notification_area {
            position: fixed;
            overflow-x: scroll;
            max-height: 100%;
            bottom: 10%;
            right: 5%;
            width: 25%;
            z-index: 96; /* 1 above the footer */
        }
        """) == "div#notification_area{position:fixed;overflow-x:scroll;max-height:100%;bottom:10%;right:5%;width:25%;z-index:96;}")
    }

    @Test func minifyCSSKeyframeSpin() {
        #expect(minify("""
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        """) == "@keyframes spin{0%{transform:rotate(0deg);}100%{transform:rotate(360deg);}}")
    }

    @Test func minifyCSSAnimation1() {
        #expect(minify("""
        .fade_750ms {
            animation: fadeEffect 0.75s;
        }
        """) == ".fade_750ms{animation:fadeEffect 0.75s;}")
    }

    @Test func minifyCSSAnimation2() {
        #expect(minify("""
        @keyframes slidein {
            0% {
                translate: 0px 2.5vw;
                opacity: 0;
            }
            100% {
                translate: 0px 0px;
                opacity: 1;
            }
        }
        """) == "@keyframes slidein{0%{translate:0px 2.5vw;opacity:0;}100%{translate:0px 0px;opacity:1;}}")
    }

    @Test func minifyCSSCalc1() {
        #expect(minify("""
        header {
            height: calc(100vh - 40px);
        }
        """) == "header{height:calc(100vh - 40px);}")
    }
}

#endif