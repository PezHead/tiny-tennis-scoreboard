//
//  MatchVictoryViewController.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

class MatchVictoryViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var partnerAvatarImageView: UIImageView!
    @IBOutlet var winnerNameLabel: UILabel!
    @IBOutlet var matchSummaryLabel: UILabel!
    
    var match: Match?
    
    fileprivate var gradientLayer: CALayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let radialLayer = RadialGradientLayer(withCenter: CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height/2 - 30))
        radialLayer.frame = view.bounds
        view.layer.insertSublayer(radialLayer, at: 0)
        
        if let match = match {
            if match.blueWins == 0 || match.redWins == 0 {
                titleLabel.text = "Total Domination"
            } else {
                titleLabel.text = "Winner"
            }
            
            
            let winners = match.matchWinningChampions
            
            if winners?.count == 1 {
                let winner = winners?.first
                
                avatarImageView.image = winner?.avatarImage
                partnerAvatarImageView.isHidden = true
                
            } else if winners?.count == 2 {
                avatarImageView.image = winners?[0].avatarImage
                partnerAvatarImageView.image = winners?[1].avatarImage
                partnerAvatarImageView.isHidden = false
            }
            
            let winnerNames = winners?.map { $0.name }.joined(separator: " / ")
            winnerNameLabel.text = winnerNames
            
            // Remove markdown formatting from summary
            matchSummaryLabel.text = match.scoreSummary.replacingOccurrences(of: "*", with: "")
        }
    }
}



// MARK: Radial Grandient Layer subclass
class RadialGradientLayer: CALayer {
    
    let centerPoint: CGPoint
    
    init(withCenter center: CGPoint) {
        self.centerPoint = center
        
        super.init()
        
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        centerPoint = CGPoint(x: 100, y: 100)
        
        super.init(coder: aDecoder)
    }
    
    override func draw(in ctx: CGContext) {
        let locations: [CGFloat] = [0.0, 1.0]
        let colors = [UIColor.white.cgColor, Chameleon.color(withHexString: "#56D1D2").withAlphaComponent(0.8).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        
        //        let radius = bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height
        let radius = CGFloat(400)
        
        ctx.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
}
