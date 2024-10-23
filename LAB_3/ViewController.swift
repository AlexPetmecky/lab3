////
//  ViewController.swift
//  LAB_3
//
//  Created by Alex Petmecky on 10/15/24.
//

import UIKit
import CoreMotion
import Lottie


class ViewController: UIViewController, MotionDelegate {
    
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var moduleBButton: UIButton!
    @IBAction func ModuleB(_ sender: Any) {   //should only appear after step goal is reached
    }
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
    
    var animationView: LottieAnimationView!
    var STEP_GOAL = 7000       //can set with button, this is default value
    let motionModel = MotionModel()
    let pedometer = CMPedometer()
    var yesterdayGoalMet: Bool = false
    
//    let dataObj = DataObj()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        congratsLabel.isHidden = true   //congrats hidden initially
        //ModuleB.isHidden = true
        
        motionModel.delegate = self           //motion updates will be updated here
        motionModel.startPedometerMonitoring()
        motionModel.startActivityMonitoring()
        
        TitleLabel.font = UIFont(name: "KohinoorTelugu-Medium", size: 27)
        stepsTodayLabel.font = UIFont(name: "KohinoorTelugu-Medium", size: 30)
        stepsYesterdayLabel.font = UIFont(name: "KohinoorTelugu-Medium", size: 20)
        activityLabel.font = UIFont(name: "KohinoorTelugu-Medium", size: 20)
        congratsLabel.font = UIFont(name: "KohinoorTelugu-Medium", size: 15)
        
        animationView = LottieAnimationView(name: "circleprogress")
        
        // Adjust the size and center horizontally
        animationView.frame = CGRect(x: 0, y: 70, width: 450, height: 450) // Set size
        animationView.center.x = view.center.x // Center it both horizontally and vertically
        animationView.contentMode = .scaleAspectFit // Maintain aspect ratio
            view.addSubview(animationView) // Add to view hierarchy
        

        congratsLabel.isHidden = true   //congrats hidden initially
        
        fetchYesterdaySteps()

        //THIS JUST RUNS ONCE SO U CAN SEE THE ANIMATINO BEFORE IT ACTUALLY CORRELATES TO STEPS , can change this or make it go faster or not have it play at all
            
//        // Start the animation
//        animationView.loopMode = .playOnce // Loop the animation
//        animationView.play() // Play the animation
        
        self.fetchYesterdaySteps()
        if (DataObj.sharedInstance.getStepsTaken()>=STEP_GOAL){
            congratsLabel.isHidden = false   //congrats hidden initially
        }
        
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
                            let yesterdaySteps = Int(truncating: data.numberOfSteps)     //just made this into a variable for clarity
                            self.stepsYesterdayLabel.text = "Yesterday's steps: \(yesterdaySteps)"
                            
                            DataObj.sharedInstance.setStepsTaken(steps: yesterdaySteps)
                            
                            self.yesterdayGoalMet = yesterdaySteps >= self.STEP_GOAL     //check if yesterdays goal was met
                            self.moduleBButton.isHidden = !self.yesterdayGoalMet    //if it was not met, hide the button
                            
                        } else {
                            self.stepsYesterdayLabel.text = "Error fetching yesterday's steps"
                            self.moduleBButton.isHidden = true   //hide button if error
                        }
                    }
                }
            }
        }
    
    @IBAction func setStepGoaltapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Set Step Goal", message: "Enter your step goal for today:", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Step goal"
                textField.keyboardType = .numberPad
            }
            
            let setAction = UIAlertAction(title: "Set", style: .default) { _ in
                if let textField = alert.textFields?.first, let text = textField.text, let goal = Int(text) {
                    self.STEP_GOAL = goal
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(setAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
    }
    
    
    func activityUpdated(activity: CMMotionActivity) {
        if activity.walking {
            activityLabel.text = "Currently: Walking \n🚶‍♂️"
        } else if activity.running {
            activityLabel.text = "Currently: Running \n🏃‍♂️"
        } else if activity.cycling {
            activityLabel.text = "Currently: Cycling \n🚴‍♂️"
        } else if activity.automotive {
            activityLabel.text = "Currently: Driving \n🚗"
        } else if activity.stationary {
            activityLabel.text = "Currently: Still \n🛑"
        } else {
            activityLabel.text = "Currently: Not sure! \n❓"
        }
    }
    
    func pedometerUpdated(pedData: CMPedometerData) {
            DispatchQueue.main.async {
                let stepsToday = pedData.numberOfSteps.intValue // Get today's step count
                let progress = min(Float(stepsToday) / Float(self.STEP_GOAL), 1.0)  // Calculate progress as a percentage, but cap it at 100%
                
                // Update the steps label
                self.stepsTodayLabel.text =  "\(stepsToday)/\(self.STEP_GOAL)"
                
                //if step goal is reached display congrats label
                if stepsToday >= self.STEP_GOAL {
                                self.congratsLabel.text = "🎉 Congratulations!\nYou have reached your step goal!"
                                self.congratsLabel.isHidden = false
                            } else {
                                self.congratsLabel.isHidden = true
                            }
                        
                
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


/*
 FOR TESTING
 func fetchYesterdaySteps() {
    let calendar = Calendar.current
    let now = Date()
    
    let simulateSteps = true
    let simulatedYesterdaySteps = 5
    
    if simulateSteps {
                DispatchQueue.main.async {
                    self.stepsYesterdayLabel.text = "Yesterday's steps: \(simulatedYesterdaySteps)"
                    DataObj.sharedInstance.setStepsTaken(steps: simulatedYesterdaySteps)
                    
                    self.yesterdayGoalMet = simulatedYesterdaySteps >= self.STEP_GOAL
                    self.moduleBButton.isHidden = !self.yesterdayGoalMet  // Show button if goal met
                    
                    if self.yesterdayGoalMet {
                        print("Test: Yesterday's step goal was met.")
                    } else {
                        print("Test: Yesterday's step goal was NOT met.")
                    }
                }
    }
    else {
        //gets start of today, minus one for start of yesterday
        if let startOfYesterday = calendar.date(byAdding: .day, value: -1, to:    calendar.startOfDay(for: now)),
           let endOfYesterday = calendar.date(byAdding: .second, value: -1, to: calendar.startOfDay(for: now)) {
            
            pedometer.queryPedometerData(from: startOfYesterday, to: endOfYesterday) { (data, error) in
                DispatchQueue.main.async {
                    if let data = data {
                        let yesterdaySteps = Int(truncating: data.numberOfSteps)     //just made this into a variable for clarity
                        self.stepsYesterdayLabel.text = "Yesterday's steps: \(yesterdaySteps)"
                        
                        DataObj.sharedInstance.setStepsTaken(steps: yesterdaySteps)
                        
                        self.yesterdayGoalMet = yesterdaySteps >= self.STEP_GOAL     //check if yesterdays goal was met
                        self.moduleBButton.isHidden = !self.yesterdayGoalMet    //if it was not met, hide the button
                        
                    } else {
                        self.stepsYesterdayLabel.text = "Error fetching yesterday's steps"
                        self.moduleBButton.isHidden = true   //hide button if error
                    }
                }
            }
        }
    }
}

 */
    

