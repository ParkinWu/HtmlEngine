//
//  OptionalExt.swift
//  HtmlEngine
//
//  Created by pzwu on 16/8/1.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import Foundation

extension Optional {
    func unwrapOrElse(op: () -> Wrapped) -> Wrapped {
        switch self {
        case .Some(let v):
            return v
        case .None:
            return op()
        }
    }
    
    func any(op: (Wrapped) -> Bool) -> Bool {
        switch self {
        case .Some(let v):
            return op(v)
        case .None:
            return false
        }
    }
    
    func unwrapOr(v :Wrapped) -> Wrapped {
        switch self {
        case .Some(let x):
            return x
        case .None:
            return v
        }
    }
}

extension Array {
    func any(op: (Element) -> Bool) -> Bool {
        for item in self {
            if op(item) {
                return true
            }
        }
        return false
    }
    
    func find(op: (Element) -> Bool) -> [Element] {
        for item in self {
            if op(item) {
                return [item]
            }
        }
        return []
    }
    
    func filterMap<U>(op: (Element) -> Optional<U>) -> [U] {
        var result:[U] = []
        for item in self {
            switch op(item) {
            case .Some(let value):
                result.append(value)
                break
            case .None:
                break
            }
        }
        return result
    }
    
    func foldLeft(base: Element, op: (Element, Element) -> Element) -> Element {
        var baseCount = base
        for ele in self {
            baseCount = op(baseCount, ele)
        }
        return baseCount
    }
    
    
    
}