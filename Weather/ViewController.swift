//
//  ViewController.swift
//  Weather
//
//  Created by E.Vladimir A. on 12.11.2017.
//  Copyright © 2017 E.Vladimir A. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func send(_ sender: UIButton) {
        let temperature = Int(textField.text!) ?? 0
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isWatchAppInstalled {
                do {
                    try session.updateApplicationContext(["temperature" : temperature])
                } catch {
                    print("Ошибка отправки контекста на часы!  \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}

