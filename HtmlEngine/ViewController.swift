//
//  ViewController.swift
//  HtmlEngine
//
//  Created by pzwu on 16/7/7.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import UIKit
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timerBegin = NSDate().timeIntervalSince1970
        let path = NSBundle.mainBundle().pathForResource("layout_test", ofType: "html")
        
        
        let source = try! NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        
        
        
        let cssPath = NSBundle.mainBundle().pathForResource("layout_test", ofType: "css")
        let cssSource = try! NSString(contentsOfFile: cssPath!, encoding: NSUTF8StringEncoding)
        
        print("-----------------------------------------")
        print(source)
        
        let html = HtmlParser.parser(source as String)
//        print(html)
//        
//        print(cssSource)
        let css = CssParser.parse(cssSource as String)
//        print(css)
//        print("-----------------------------------------")
        let styleTree = Style.styleTree(html, stylesheet: css)
        
//        print(styleTree)
        
//        print("-----------------------------------------\n")
        
        var viewport = Layout.Dimensions()
        viewport.content.width = Float(UIScreen.mainScreen().bounds.size.width)
        viewport.content.height = Float(UIScreen.mainScreen().bounds.size.height)
        
        
        let layoutTree = Layout.layoutTree(styleTree, containerBlock: viewport)
        let timerEnd = NSDate().timeIntervalSince1970
        
        print(timerEnd - timerBegin)
        print(layoutTree)
        
        Printer.printLayoutBox(layoutTree, containerView: self.view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

