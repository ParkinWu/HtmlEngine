//
//  BaseParser.swift
//  HtmlEngine
//
//  Created by pzwu on 16/7/11.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import UIKit

class BaseParser: NSObject {
    
    var pos: Int
    var input: String
    
    init(pos: Int, input: String) {
        self.pos = pos
        self.input = input
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
