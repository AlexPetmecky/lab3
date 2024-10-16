//
//  MotionModel.swift
//  LAB_3
//
//  Created by Alex Petmecky on 10/15/24.
//


import CoreMotion

// setup a protocol for the ViewController to be delegate for
protocol MotionDelegate {
    // Define delegate functions
    func activityUpdated(activity:CMMotionActivity)
    func pedometerUpdated(pedData:CMPedometerData)
}

class MotionModel{
    
    // MARK: =====Class Variables=====
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    var delegate:MotionDelegate? = nil
    
    // MARK: =====Motion Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            {(activity:CMMotionActivity?)->Void in
                // unwrap the activity and send to delegate
                // using the real time pedometer might influences how often we get activity updates...
                // so these updates can come through less often than we may want
                if let unwrappedActivity = activity,
                   let delegate = self.delegate {
                    // Print if we are walking or running
                    print("%@",unwrappedActivity.description)
                    
                    // Call delegate function
                    delegate.activityUpdated(activity: unwrappedActivity)
                    
                }
            }
        }
        
    }
    
    func startPedometerMonitoring(){
        // check if pedometer is okay to use
        if CMPedometer.isStepCountingAvailable(){
            // start updating the pedometer from the current date and time
            pedometer.startUpdates(from: Date())
            {(pedData:CMPedometerData?, error:Error?)->Void in
                
                // if no errors, update the delegate
                if let unwrappedPedData = pedData,
                   let delegate = self.delegate {
                    
                    delegate.pedometerUpdated(pedData:unwrappedPedData)
                }

            }
        }
    }
    
    
}
