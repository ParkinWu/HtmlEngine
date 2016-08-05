//
//  CssParser.swift
//  HtmlEngine
//
//  Created by pzwu on 16/7/11.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import UIKit

class CssParser: BaseParser {
    
    class func parse(source: String) -> DOM.StyleSheet {
        let parser = CssParser(pos: 0, input: source)
        return DOM.StyleSheet(rules: parser.parseRules())
    }
    
    func parseRules() -> [DOM.Rule] {
        var rules:[DOM.Rule] = []
        
        while true {
            consumeWhitespace()
            if self.eof() {
                break
            }
            rules.append(parseRule())
        }
        return rules
    }
    
    func parseRule() -> DOM.Rule {
        return DOM.Rule(selectors: parseSelectors(), declarations: parseDeclarations())
    }
    
    func parseSelectors() -> [DOM.Selector] {
        var selectors:[DOM.Selector] = []
        var loop = true
        while loop {
            consumeWhitespace()
            selectors.append(DOM.Selector.Simple(parseSimpleSelector()))
//            selectors.append(DOM.Selector(selector: parseSimpleSelector()))
            
            switch nextChar() {
            case ",":
                self.consumeChar()
                self.consumeWhitespace()
                break
            case "{":
                loop = false
                break
            default:
                assert(false, "Unexpected character {} in selector list")
            }
            
        }
        
        selectors.sortInPlace { (a, b) -> Bool in
            return a.specificity() < b.specificity()
        }
        
        return selectors
        
        
    }
    func parseSimpleSelector() -> DOM.SimpleSelector {
        var selector = DOM.SimpleSelector(tagName: nil, id: nil, cls: [])
        var loop = true
        while !self.eof() && loop {
            consumeWhitespace()
            let c = nextChar()
            switch c {
            case "#":
                self.consumeChar()
                selector.id = .Some(parseIdentifier())
                break
            case ".":
                self.consumeChar()
                selector.cls.append(parseIdentifier())
                break
            case "*":
                self.consumeChar()
                break
            default:
                if validIdentifierChar(c) {
                    selector.tagName = .Some(parseIdentifier())
                } else {
                    loop = false
                    break
                }
            }
        }
        return selector
        
    }
    func parseDeclarations() -> [DOM.Declaration] {
        assert(consumeChar() == "{")
        var declarations:[DOM.Declaration] = []
        while true {
            consumeWhitespace()
            if nextChar() == "}" {
                consumeChar()
                break
            }
            declarations.append(parseDeclaration())
            
        }
        return declarations
        
    }
    
    func parseDeclaration() -> DOM.Declaration {
        let propName = parseIdentifier()
        consumeWhitespace()
        assert(consumeChar() == ":")
        consumeWhitespace()
        let propValue = parseValue()
        consumeWhitespace()
        assert(consumeChar() == ";")
        return DOM.Declaration(name: propName, value: propValue)
        
    }
    
    func parseValue() -> DOM.Value {
        switch nextChar() {
        case "0"..."9":
            return parseLength()
        case "#":
            return parseColor()
        default:
            return parseKeyword()
        }
    }

    func parseLength() -> DOM.Value {
        return DOM.Value.Length(parseFloat(), parseUnit())
    }
    
    func parseColor() -> DOM.Value {
        assert(consumeChar() == "#")
        return DOM.Value.ColorValue(DOM.Color(r: parseHexPair(), g: parseHexPair(), b: parseHexPair(), a: 255))
    }
    
    func parseKeyword() -> DOM.Value {
        return DOM.Value.Keyword(parseIdentifier())
    }
    
    
    func parseIdentifier() -> String {
        return consumeWhile(validIdentifierChar)
    }
    
    func parseFloat() -> Float {
        let s = consumeWhile { (c) -> Bool in
            switch c {
                case "0"..."9":
                    return true
                case ".":
                    return true
                default:
                    return false
            }
        }
        return (s as NSString).floatValue
        
    }
    
    func parseHexPair() -> UInt8 {
        let s = input[pos...pos + 1]
        pos = pos + 2
        return UInt8(strtol(s, nil, 16))
    }
    func parseUnit() -> DOM.Unit {
        switch parseIdentifier().lowercaseString {
        case "px":
            return DOM.Unit.Px
        default:
            assert(false, "unrecognized unit")
            break
        }
    }
    
    func validIdentifierChar(c: Character) -> Bool {
        switch c {
        case "a"..."z":
            return true
        case "A"..."Z":
            return true
        case "0"..."9":
            return true
        case "-":
            return true
        case "_":
            return true
        default:
            return false
        }
    }
    
    
    

}
