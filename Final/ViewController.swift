//
//  ViewController.swift
//  Final
//
//  Created by Hyungsuk Kang on 11/13/16.
//  Copyright © 2016 Hyungsuk Kang. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    @IBOutlet weak var amplitudeLabel: UILabel!
    
    @IBOutlet weak var audioInputPlot: EZAudioPlot!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        AudioKit.start()
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
    }

    func updateUI() {
            amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

