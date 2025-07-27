
#if compiler(>=6.0)

import Testing
@testable import JavaScript
@testable import SwiftCompressionUtilities

// MARK: JavaScriptTests
struct JavaScriptTests {
}

// MARK: JavaScriptMinifyTests
struct JavaScriptMinifyTests {
    private func minify(_ string: String) -> String {
        return String(decoding: CompressionTechnique.javascript.minify(data: [UInt8](string.utf8)), as: UTF8.self)
    }

    @Test func minifyJSVar() {
        #expect(minify("""
        var i = 0;
        var j = "easy clap";
        var k = false;
        """) == """
        var i=0;var j="easy clap";var k=false;
        """)
    }

    @Test func minifyJSConst() {
        #expect(minify("""
        const i = 0;
        const j = "easy clap";
        const k = false;
        """) == """
        const i=0;const j="easy clap";const k=false;
        """)
    }

    @Test func minifyJSForNumber() {
        #expect(minify("""
        for (var i = 0; i < starting_time_elements.length - 1; i++) {
        }
        """) == """
        for(var i=0;i<starting_time_elements.length-1;i++){}
        """)
    }

    @Test func minifyJSForOf1() {
        #expect(minify("""
        for (const [bracket, bracket_rounds] of Object.entries(bracket_matchups)) {
        }
        """) == """
        for(const [bracket,bracket_rounds] of Object.entries(bracket_matchups)){}
        """)
    }
    @Test func minifyJSForOf2() {
        #expect(minify("""
        for (element of missing_elements) {
        }
        """) == "for(element of missing_elements){}")
    }

    @Test func minifyJSDefault() {
        #expect(minify("""
        function get_user_agent() {
            return window.navigator.userAgent;
        }
        """) == "function get_user_agent(){return window.navigator.userAgent;}")
    }

    @Test func minifyJSTypeof() {
        #expect(minify("""
        if (typeof target_value === 'string') {
            time = target_value;
        }
        """) == """
        if(typeof target_value==='string'){time=target_value;}
        """)
    }

    @Test func minifyJSStringToken1() {
        #expect(minify("""
        divisions_list_html += ("<div class='row division_entry'><div class='col-100'>Name " + division_name + " | Day of Week " + day_of_week_html + "</div></div>")
        """) == """
        divisions_list_html+=("<div class='row division_entry'><div class='col-100'>Name "+division_name+" | Day of Week "+day_of_week_html+"</div></div>")
        """)
    }
    @Test func minifyJSStringToken2() {
        #expect(minify("""
        function get_cookie(name) {
            return document.cookie.match('(^|;)\\s*' + name + '\\s*=\\s*([^;]+)')?.pop() || '';
        }
        """) == "function get_cookie(name){return document.cookie.match('(^|;)\\s*'+name+'\\s*=\\s*([^;]+)')?.pop()||'';}")
    }

    @Test func minifyJSStringToken3() {
        #expect(minify("""
        var string = `
        <html>
            <head>
                <meta charset="UTF-8">
                <title>League Schedule Diagnostics: %schedule_id%</title>
                <link rel="stylesheet" type="text/css" href="/css/defaults.css">
                <link rel="stylesheet" type="text/css" href="/css/scheduler.css">
                <script async type="text/javascript" src="/js/defaults.js"></script>
                <script async type="text/javascript" src="/js/scheduler.js"></script>
            </head>
            <body>
                <h1>League Schedule Diagnostics: %schedule_id%</h1>
        `;
        """) == """
        var string=`
        <html>
            <head>
                <meta charset="UTF-8">
                <title>League Schedule Diagnostics: %schedule_id%</title>
                <link rel="stylesheet" type="text/css" href="/css/defaults.css">
                <link rel="stylesheet" type="text/css" href="/css/scheduler.css">
                <script async type="text/javascript" src="/js/defaults.js"></script>
                <script async type="text/javascript" src="/js/scheduler.js"></script>
            </head>
            <body>
                <h1>League Schedule Diagnostics: %schedule_id%</h1>
        `;
        """)
    }

    @Test func minifyJSSwitchCaseString() {
        #expect(minify("""
        switch (key) {
        case "opponents":
            break;
        case "home_away":
            break;
        case "time_slots":
            break;
        case "matchup_slots":
            break;
        default:
            break;
        }
        """) == """
        switch(key){case"opponents":break;case"home_away":break;case"time_slots":break;case"matchup_slots":break;default:break;}
        """)
    }

    @Test func minifyJSSwitchCaseNumber() {
        #expect(minify("""
        switch (brackets.size) {
        case 2:
            bracket_names.push("Winners Bracket");
            bracket_names.push("Losers Bracket");
            break;
        case 3:
            bracket_names.push("Winners Bracket");
            bracket_names.push("Losers Bracket");
            bracket_names.push("Elimination Bracket");
            break;
        default:
            for (var i = 0; i < brackets.size; i++) {
                bracket_names.push("Bracket " + (i + 1).toString());
            }
            break;
        }
        """) == """
        switch(brackets.size){case 2:bracket_names.push("Winners Bracket");bracket_names.push("Losers Bracket");break;case 3:bracket_names.push("Winners Bracket");bracket_names.push("Losers Bracket");bracket_names.push("Elimination Bracket");break;default:for(var i=0;i<brackets.size;i++){bracket_names.push("Bracket "+(i+1).toString());}break;}
        """)
    }

    @Test func minifyJSComments1() {
        #expect(minify("""
        // MARK: Login
        function toggle_login_details() {
            const login_element = getElement("login");
            if (login_element.style.display == "none") { // show
                login_element.style.removeProperty("display");
            } else { // hide
                login_element.style.display = "none";
            }
        }
        """) == """
        function toggle_login_details(){const login_element=getElement("login");if(login_element.style.display=="none"){login_element.style.removeProperty("display");}else{login_element.style.display="none";}}
        """)
    }
    
    @Test func minifyJSComments2() {
        #expect(minify("""
        /* MARK: Login
        function toggle_login_details() {
            const login_element = getElement("login");
            if (login_element.style.display == "none") { // show
                login_element.style.removeProperty("display");
            } else { // hide
                login_element.style.display = "none";
            }
        }*/function test() {}
        """) == "function test(){}")
    }

    @Test func minifyJSDivision1() {
        #expect(minify("""
        Math.floor(1 / 2);
        """) == "Math.floor(1/2);")
    }
    @Test func minifyJSDivision2() {
        #expect(minify("""
        Math.floor(entries_count / divisions_count);
        """) == "Math.floor(entries_count/divisions_count);")
    }

    @Test func minifyJSInstanceof() {
        #expect(minify("""
        const reason = item instanceof Error ? item.message : new Error(item).message;
        """) == "const reason=item instanceof Error?item.message:new Error(item).message;")
    }
}

#endif