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
        let path = NSBundle.mainBundle().pathForResource("index", ofType: "html")
        
        
        let source = try! NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        
        print(source)
        
        print(source.length)
        print(parser(source as String))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

