//
//  ViewController.swift
//  Markdown
//
//  Created by kafejo on 03/06/2018.
//  Copyright (c) 2018 kafejo. All rights reserved.
//

import UIKit
import Markdown

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let path = Bundle.main.path(forResource: "test", ofType: "md") {
            let md = try! String(contentsOfFile: path, encoding: .utf8)
            contentView.attributedText = Markdown.attributedString(fromMarkdown: md)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

