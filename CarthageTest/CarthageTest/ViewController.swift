//
//  ViewController.swift
//  CarthageTest
//
//  Created by arsen.vartbaronov on 26.07.17.
//  Copyright © 2017 Webtrekk. All rights reserved.
//

import UIKit
import Webtrekk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        WebtrekkTracking.defaultLogger.minimumLevel = .debug
        try! WebtrekkTracking.initTrack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

