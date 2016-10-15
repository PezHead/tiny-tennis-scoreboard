//
//  Input.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

protocol Input {
    ///  Prepares the input device to be ready to use.
    ///
    ///  - returns: true if the device was succesfully initialized and ready to go, else false.
    func initialize() -> Bool
    
    weak var delegate: InputDelegate? { get set }
}

protocol InputDelegate: class {
    func addScoreLeft()
    func addScoreRight()
    func undoLastPoint()
}


/// Manages input using Flick buttons.
class FlicInput: NSObject, Input, SCLFlicManagerDelegate, SCLFlicButtonDelegate {
    // Properties
    weak var delegate: InputDelegate?
    
    private var buttonMap = [UUID : Team]()
    private var lastButtonPress = TimeInterval(0)
    
    
    // Input protocol methods
    func initialize() -> Bool {
        guard SCLFlicManager.shared() == nil else { return false }
        
        let check = SCLFlicManager.configure(with: self, defaultButtonDelegate: self, appID: "8e805991-0da4-4c74-a186-6bb97c731378", appSecret: "134daedd-6807-4ebc-9d51-c9e4c11315b3", backgroundExecution: false)
        
        if check != nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Flic Delegate Methods
    @objc func flicManager(_ manager: SCLFlicManager, didGrab button: SCLFlicButton?, withError error: Error?) {
        button?.triggerBehavior = .clickAndHold
        button?.delegate = self
        
        // FIXME: Duplicated code from restoreState
        if button?.userAssignedName == "Blue" {
            buttonMap[(button?.buttonIdentifier)!] = .red
        } else if button?.userAssignedName == "Green" {
            buttonMap[(button?.buttonIdentifier)!] = .blue
        }
    }
    
    func flicManagerDidRestoreState(_ manager: SCLFlicManager) {
        if manager.knownButtons().count < 2 {
            SCLFlicManager.shared()?.grabFlicFromFlicApp(withCallbackUrlScheme: Config.urlScheme)
        } else {
            for (uuid, button) in manager.knownButtons() {
                button.triggerBehavior = .clickAndHold
                button.delegate = self
                
                if button.userAssignedName == "Blue" {
                    buttonMap[uuid] = .red
                } else if button.userAssignedName == "Green" {
                    buttonMap[uuid] = .blue
                }
            }
        }
    }
    
    func flicButton(_ button: SCLFlicButton, didReceiveButtonClick queued: Bool, age: Int) {
        guard queued == false else { return }
        
        // Try to avoid accidental rapid-fire single clicks.
        guard NSDate.timeIntervalSinceReferenceDate - lastButtonPress > 1.5 else { return }
        
        // add point red/blue
        if buttonMap[button.buttonIdentifier] == .red {
            delegate?.addScoreLeft()
        } else if buttonMap[button.buttonIdentifier] == .blue {
            delegate?.addScoreRight()
        } else {
            fatalError("single click received from a button that is not currently mapped!")
        }
        
        lastButtonPress = NSDate.timeIntervalSinceReferenceDate
    }
    
    func flicButton(_ button: SCLFlicButton, didReceiveButtonHold queued: Bool, age: Int) {
        guard queued == false else { return }
        
        delegate?.undoLastPoint()
    }
}
