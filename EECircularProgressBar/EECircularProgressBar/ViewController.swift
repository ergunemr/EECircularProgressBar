//
//  ViewController.swift
//  ColorfulProgressBar
//
//  Created by Emre on 1.10.2018.
//  Copyright © 2018 Emre. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var differentColorsProgressBar: EECircularProgressBar! {
        didSet {
            differentColorsProgressBar.levelColors = prepareColors(forProgressBar: differentColorsProgressBar)
            differentColorsProgressBar.animationDuration = 2.0
            differentColorsProgressBar.levelLineCap = .round
            differentColorsProgressBar.delegate = self
            differentColorsProgressBar.progressLabelFont = UIFont.boldSystemFont(ofSize: 24)
        }
    }
    
    @IBOutlet weak var oneColorProgressBar: EECircularProgressBar! {
        didSet {
            oneColorProgressBar.levelColors = prepareColors(forProgressBar: oneColorProgressBar)
            oneColorProgressBar.animationDuration = 2.0
            oneColorProgressBar.levelLineCap = .round
            oneColorProgressBar.progressLabelFont = UIFont.boldSystemFont(ofSize: 24)
        }
    }
    
    @IBOutlet weak var twoColorsProgressBar: EECircularProgressBar! {
        didSet {
            twoColorsProgressBar.levelColors = prepareColors(forProgressBar: twoColorsProgressBar)
            twoColorsProgressBar.animationDuration = 2.0
            twoColorsProgressBar.levelLineCap = .round
            twoColorsProgressBar.progressLabelFont = UIFont.boldSystemFont(ofSize: 24)
        }
    }
    
    @IBOutlet weak var levelTextField: UITextField!
    
    func prepareColors(forProgressBar progressBar: EECircularProgressBar) -> [UIColor] {
        
        if progressBar == differentColorsProgressBar {
            let green = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            let yellow = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            let red = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            return [red, yellow, green]
        } else if progressBar == twoColorsProgressBar {
            let pumpkin = UIColor(red: 211/255, green: 84/255, blue: 0/255, alpha: 1)
            let midnightBlue = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
            return [pumpkin, midnightBlue]
        } else {
            let greenSea = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
            return [greenSea]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func startTapped(_ sender: UIButton) {
        differentColorsProgressBar.animate(toPercent: 0.8)
        twoColorsProgressBar.animate(toPercent: 0.9)
        oneColorProgressBar.animate(toPercent: 0.4)
    }
}

extension ViewController: EECircularProgressBarDelegate {
    func trackAnimationDidStart(_ dynamicColorBar: EECircularProgressBar) {
        print("EEDynamicColorBar animationDidStart")
    }
    
    func trackAnimating(_ dynamicColorBar: EECircularProgressBar, currentProgress: Double) {
        print("EEDynamicColorBar animating: \(currentProgress)")
    }
    
    func trackAnimationDidEnd(_ dynamicColorBar: EECircularProgressBar) {
        print("EEDynamicColorBar animationDidEnd")
    }
}
