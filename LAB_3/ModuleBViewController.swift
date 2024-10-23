//
//  ModuleBViewController.swift
//  LAB_3
//
//  Created by Alex Petmecky on 10/20/24.
//

import UIKit
import SpriteKit

class ModuleBViewController: UIViewController {

//    let dataObj = DataObj()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if(DataObj.sharedInstance.hasOpened == 0){
//            DataObj.sharedInstance.setStepsTaken(steps: 10000)
//            DataObj.sharedInstance.hasOpened = 1
//        }
        var stepData = DataObj.sharedInstance.getStepsTaken()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
