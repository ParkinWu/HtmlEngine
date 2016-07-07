//
//  HtmlEngine.swift
//  HtmlEngine
//
//  Created by pzwu on 16/7/7.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import Foundation

import UIKit


struct Node {
    var children: Array<Node>
    var nodeType: NodeType
}


enum NodeType {
    case Text(String)
    case Element(ElementData)
}

struct ElementData {
    var tagName: String
    var attributes: AttrMap
    
}

typealias AttrMap = Dictionary<String, String>

func text(data: String) -> Node {
    return Node(children: [], nodeType: .Text(data))
}

func elem(name: String, attrs: AttrMap, children: Array<Node>) -> Node {
    return Node(children: children, nodeType: .Element(ElementData(tagName: name, attributes: attrs)))
}

func parser(source: String) -> Node {
    let nodes = Parser(pos: 0, input: source).parserNodes()
    if nodes.count == 1 {
        return nodes[0]
    } else {
        return elem("html", attrs: Dictionary(), children: nodes)
    }
}
class Parser {
    var pos: Int
    var input: String
    
    init(pos: Int, input: String) {
        self.pos = pos
        self.input = input
    }
    
    func parserNodes() -> [Node] {
        var nodes:[Node] = []
        while true {
            
            consumeWhitespace()
            
            if self.eof() || self.startWith("</") {
                break
            }
            
            nodes.append(self.parserNode())
            
            
        }
        return nodes
        
    }
    
    func parserNode() -> Node {
     
        switch self.nextChar() {
        case "<":
            return self.parserElement()
        default:
            return self.parserText()
        }
    }
    
    func parserElement() -> Node {
        assert(self.consumeChar() == "<")
        let tagName = parserTagName()
        let attrs = parserAttributes()
        assert(self.consumeChar() == ">")
        
        let childrens = parserNodes()
        assert(consumeChar() == "<")
        assert(consumeChar() == "/")
        assert(parserTagName() == tagName)
        assert(consumeChar() == ">")
        print("parser Element: \(tagName), \(attrs)")
        return elem(tagName, attrs: attrs, children: childrens)
    }
    func parserText() -> Node {
        return text(consumeWhile({ (char) -> Bool in
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
    func parserAttributes() -> AttrMap {
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
    func startWith(str: String) -> Bool {
        let index = self.input.startIndex.advancedBy(pos)
        return self.input.substringFromIndex(index).hasPrefix(str)
    }
    func consumeChar() -> Character {
        let char:Character = self.input[pos]
        pos += 1
        return char
        
    }
    func consumeWhitespace() {
        consumeWhile { (char) -> Bool in
            return char == " " || char == "\n"
        }
    }
    
    func consumeWhile(test: (Character -> Bool)) -> String {
        var result: String = ""
        while !self.eof() && test(self.nextChar()) {
            result.append(self.consumeChar())
        }
        return result
    }
    
    func eof() -> Bool {
        return self.pos >= self.input.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }
    
    func nextChar() -> Character {
        return input[pos]
    }
}

