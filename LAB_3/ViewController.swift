//
//  ViewController.swift
//  LAB_3
//
//  Created by Alex Petmecky on 10/15/24.
//

import UIKit
import CoreMotion
import Lottie


class ViewController: UIViewController, MotionDelegate {
    
    @IBOutlet weak var stepsTodayLabel: UILabel!      //create labels to show todays steps and yest
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBAction func ModuleB(_ sender: Any) {   //should only appear after step goal is reached
    }
    
    var animationView: LottieAnimationView!
    
    var STEP_GOAL = 100
    let motionModel = MotionModel()
    let pedometer = CMPedometer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionModel.delegate = self           //motion updates will be updated here
        motionModel.startPedometerMonitoring()
        motionModel.startActivityMonitoring()
        
        animationView = LottieAnimationView(name: "circleprogress")
        
        // Adjust the size and center both horizontally and vertically
            animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400) // Set size
            animationView.center = view.center // Center it both horizontally and vertically
            animationView.contentMode = .scaleAspectFit // Maintain aspect ratio
            view.addSubview(animationView) // Add to view hierarchy
            
            // Start the animation
            animationView.loopMode = .playOnce // Loop the animation
            animationView.play() // Play the animation
    }
    
    func fetchYesterdaySteps() {
        let calendar = Calendar.current
        let now = Date()
        
        
        //gets start of today, minus one for start of yesterday
        if let startOfYesterday = calendar.date(byAdding: .day, value: -1, to:    calendar.startOfDay(for: now)),
           let endOfYesterday = calendar.date(byAdding: .second, value: -1, to: calendar.startOfDay(for: now)) {
            
            pedometer.queryPedometerData(from: startOfYesterday, to: endOfYesterday) { (data, error) in
                DispatchQueue.main.async {
                    if let data = data {
                        self.stepsYesterdayLabel.text = "Yesterday's steps: \(data.numberOfSteps)"
                    } else {
                        self.stepsYesterdayLabel.text = "Error fetching yesterday's steps"
                    }
                }
            }
        }
    }
    
    func fetchTodaySteps() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date()) // Change this if Apple's Health app uses a different start time, e.g., 4 AM
        
        pedometer.queryPedometerData(from: startOfToday, to: Date()) { (data, error) in
            DispatchQueue.main.async {
                if let data = data {
                    self.stepsTodayLabel.text = "Today's steps: \(data.numberOfSteps)"
                } else {
                    self.stepsTodayLabel.text = "Error fetching today's steps"
                }
            }
        }
    }
    
    
    func activityUpdated(activity: CMMotionActivity) {
        if activity.walking {
            activityLabel.text = "🚶‍♂️"  // Walking emoji
        } else if activity.running {
            activityLabel.text = "🏃‍♂️"  // Running emoji
        } else if activity.cycling {
            activityLabel.text = "🚴‍♂️"  // Cycling emoji
        } else if activity.automotive {
            activityLabel.text = "🚗"  // Driving emoji
        } else if activity.stationary {
            activityLabel.text = "🛑"  // Still emoji
        } else {
            activityLabel.text = "❓"  // Unknown emoji
        }
    }
    
    func pedometerUpdated(pedData: CMPedometerData) {
            DispatchQueue.main.async {
                let stepsToday = pedData.numberOfSteps.intValue // Get today's step count
                let progress = min(Float(stepsToday) / Float(self.STEP_GOAL), 1.0)  // Calculate progress as a percentage, but cap it at 100%
                
                // Update the steps label
                self.stepsTodayLabel.text = "Today's steps: \(stepsToday)"
                
                // Update the progress of the animation based on the step count
                self.animationView.currentProgress = CGFloat(progress)  // Set animation progress based on steps
                self.animationView.play(fromProgress: CGFloat(progress - 0.01), toProgress: CGFloat(progress), loopMode: .none) // Play the animation from the previous progress to the new one
            }
        }
    
}//end of view controller
    
   


/*  //github for refernce: https://github.com/SMU-MSLC/Commotion/blob/3_RawMotionUI/Commotion/ViewController.swift
     
     //PAST PEDOMETER DATA https://developer.apple.com/documentation/coremotion/cmpedometer/1613946-querypedometerdatafromdate?language=objc
     
     //SAVING TO USER DEFAULTS https://developer.apple.com/documentation/foundation/userdefaults#topics
     
     */
    

