//
//  HtmlParser.swift
//  HtmlEngine
//
//  Created by pzwu on 16/7/11.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import UIKit

class HtmlParser: BaseParser {
    
    
    class func parser(source: String) -> DOM.Node {
        let nodes = HtmlParser(pos: 0, input: source).parserNodes()
        if nodes.count == 1 {
            return nodes[0]
        } else {
            return DOM.elem("html", attrs: Dictionary(), children: nodes)
        }
    }
    
    func parserNodes() -> [DOM.Node] {
        var nodes:[DOM.Node] = []
        while true {
            
            consumeWhitespace()
            
            if self.eof() || self.startWith("</") {
                break
            }
            
            nodes.append(self.parserNode())
            
            
        }
        return nodes
        
    }
    
    func parserNode() -> DOM.Node {
        
        switch self.nextChar() {
        case "<":
            return self.parserElement()
        default:
            return self.parserText()
        }
    }
    
    func parserElement() -> DOM.Node {
        assert(self.consumeChar() == "<")
        let tagName = parserTagName()
        let attrs = parserAttributes()
        assert(self.consumeChar() == ">")
        
        let childrens = parserNodes()
        assert(consumeChar() == "<")
        assert(consumeChar() == "/")
        assert(parserTagName() == tagName)
        assert(consumeChar() == ">")
        return DOM.elem(tagName, attrs: attrs, children: childrens)
    }
    func parserText() -> DOM.Node {
        return DOM.text(consumeWhile({ (char) -> Bool in
            return char != "<"
        }))
        
    }
    
    func parserTagName() -> String {
        return self.consumeWhile { (char) -> Bool in
            switch char {
            case "a"..."z":
                return true
            case "A"..."Z":
                return true
            case "0"..."9":
                return true
            default:
                return false
            }
        }
    }
    func parserAttributes() -> DOM.AttrMap {
        var attr:[String:String] = [:]
        while true {
            consumeWhitespace()
            if nextChar() == ">" {
                break
            }
            let (name, value) = parserAttr()
            attr[name] = value
            
        }
        
        return attr
    }
    
    func parserAttr() -> (String, String) {
        let name = parserTagName()
        consumeWhitespace()
        assert(self.consumeChar() == "=")
        consumeWhitespace()
        let value = parserAttrValue()
        return (name, value)
    }
    func parserAttrValue() -> String {
        let openQuote = consumeChar()
        assert(openQuote == "\"" || openQuote == "'")
        let value = consumeWhile { (char) -> Bool in
            return char != openQuote
        }
        assert(consumeChar() == openQuote)
        
        return value
    }
   
}
