//
//  FruitButtons.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/26/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

class FruitButton: NSObject, Input, StreamDelegate {
    private var inStream: InputStream!
    private let address: CFString = Config.fruitAddress as CFString
    private let port: UInt32 = Config.fruitPort
    
    weak var delegate: InputDelegate?
    
    func initialize() -> Bool {
        var readStream: Unmanaged<CFReadStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, address, port, &readStream, nil)
        
        inStream = readStream!.takeRetainedValue()
        inStream.delegate = self
        inStream.schedule(in: .current, forMode: .defaultRunLoopMode)
        inStream.open()
        
        return true
    }
    
    // MARK: - StreamDelegate
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode.contains(.openCompleted) {
            print("stream opened")
        } else if eventCode.contains(.hasBytesAvailable) {
            print("bytes available!")
            
            if aStream == inStream {
                var buffer = [UInt8](repeating: 0, count: 100)
                
                while (inStream.hasBytesAvailable) {
                    _ = inStream.read(&buffer, maxLength: buffer.count)
                    if let incomingData = String(bytes: buffer, encoding: .utf8) {
                        print(incomingData)
                        
                        // Parse button protocol
                        // example - "side:A,button:1,press:single"
                        let pieces = incomingData.components(separatedBy: ",")
                        
                        let side = pieces.first
                        if side?.characters.last == "A" {
                            delegate?.addScoreLeft()
                        } else if side?.characters.last == "B" {
                            delegate?.addScoreRight()
                        } else {
                            print("I can't do that Dave.")
                        }
                    }
                }
            }
        }
    }
}
