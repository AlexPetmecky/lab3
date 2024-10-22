//
//  DataObj.swift
//  LAB_3
//
//  Created by Alex Petmecky on 10/22/24.
//

import UIKit

class DataObj: NSObject {
    static let sharedInstance = DataObj()
    
    var stepsTaken = 0
    
    func setStepsTaken(steps:Int){
        self.stepsTaken = steps
    }
    
    func getStepsTaken()->Int{
        return self.stepsTaken
    }
}
