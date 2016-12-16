//
//  ViewController.swift
//  MicrophoneAnalysis
//
//  Created by Kanstantsin Linou on 6/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import CoreMotion
import AVFoundation
import AudioToolbox



class ViewController: UIViewController {
    
    var timer = Timer()
    var isPlaying = false
    var startTime = TimeInterval()
    var isPaused:Bool = false
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var amplitudeLabel: UILabel!
    @IBOutlet var apneaCountLabel: UILabel!
    @IBOutlet var audioInputPlot: EZAudioPlot!
    @IBAction func startTimer(_ sender: AnyObject) {
        if !timer.isValid {
            
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector,     userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate
            
            
            
            //Audio Analysis
            AudioKit.output = silence
            AudioKit.start()
            setupPlot()
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
            
        }
        
        
        
        
    }
    
    @IBAction func pauseTimer(_ sender: AnyObject) {
        timer.invalidate()
        isPaused = true
        
    }
    
    @IBAction func resetTimer(_ sender: AnyObject) {
        
        timer.invalidate()
        timeLabel.text = "00:00:00"
    }
    
    
    
    
    // Variables
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    lazy var motionManager = CMMotionManager()
    var count: Int = 0
    lazy var before: Double = 0
    var isApnea:Bool = false
    var apneaCount = 0
    var audioPlayer = AVAudioPlayer()
    
    
    
    
    
    // Plot for Audio Analysis
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame:audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MIC
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    
    func updateUI() {
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
        count += 1
        print("Before: \(before)")
        print(tracker.amplitude)
        print(count)
        print(isApnea)
        print((abs(tracker.amplitude - before) / tracker.amplitude))
        if((abs(tracker.amplitude - before) / tracker.amplitude) < 1) {
            isApnea = true
        }
        else {
            isApnea = false
            count = 0
        }
        if( count == 110) {
            count = 0
            if(isApnea) {
                apneaCount += 1
                apneaCountLabel.text = String(apneaCount)
                AudioServicesPlaySystemSound(1000)
            }
        }
        
        before = tracker.amplitude
    }
    
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        timeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        
    }
    
    
    
}

