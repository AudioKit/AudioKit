//
//  AKResourceAudioFileLoaderView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

open class AKResourcesAudioFileLoaderView: UIView {
    
    var player: AKAudioPlayer?
    var stopOuterPath = UIBezierPath()
    var playOuterPath = UIBezierPath()
    var upOuterPath = UIBezierPath()
    var downOuterPath = UIBezierPath()
    
    var currentIndex = 0
    var titles = [String]()
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            var isFileChanged = false
            let isPlayerPlaying = player!.isPlaying
            let touchLocation = touch.location(in: self)
            if stopOuterPath.contains(touchLocation) {
                player?.stop()
            }
            if playOuterPath.contains(touchLocation) {
                player?.play()
            }
            if upOuterPath.contains(touchLocation) {
                currentIndex -= 1
                isFileChanged = true
            }
            if downOuterPath.contains(touchLocation) {
                currentIndex += 1
                isFileChanged = true
            }
            if currentIndex < 0 { currentIndex = titles.count - 1 }
            if currentIndex >= titles.count { currentIndex = 0 }
            
            if isFileChanged {
                player?.stop()
                let filename = titles[currentIndex]
                let file = try? AKAudioFile(readFileName: "\(filename)", baseDir: .resources)
                do {
                    try player?.replace(file: file!)
                } catch {
                    AKLog("Could not replace file")
                }
                if isPlayerPlaying { player?.play() }
                setNeedsDisplay()
            }
        }
    }
    
    public convenience init(player: AKAudioPlayer, filenames: [String], frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60)) {
        self.init(frame: frame)
        self.player = player
        self.titles = filenames
    }
    
    func drawAudioFileLoader(fileName: String = "None") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let sliderColor = UIColor(red: 1.000, green: 0.000, blue: 0.062, alpha: 1.000)
        let backgroundColor = UIColor(red: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let color = UIColor(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000)
        let dark = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        let darkgray = UIColor(red: 0.735, green: 0.742, blue: 0.736, alpha: 1.000)
        
        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 440, height: 60))
        darkgray.setFill()
        backgroundPath.fill()
    
        //// stopButton
        //// stopOuter Drawing
        stopOuterPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 60, height: 60))
        sliderColor.setFill()
        stopOuterPath.fill()
        
        //// stopInner Drawing
        let stopInnerPath = UIBezierPath(rect: CGRect(x: 15, y: 15, width: 30, height: 30))
        dark.setFill()
        stopInnerPath.fill()
        
        //// playButton
        //// playOuter Drawing
        playOuterPath = UIBezierPath(rect: CGRect(x: 60, y: 0, width: 60, height: 60))
        color.setFill()
        playOuterPath.fill()
        
        //// playInner Drawing
        let playInnerPath = UIBezierPath()
        playInnerPath.move(to: CGPoint(x: 76.5, y: 15))
        playInnerPath.addLine(to: CGPoint(x: 76.5, y: 45))
        playInnerPath.addLine(to: CGPoint(x: 106.5, y: 30))
        dark.setFill()
        playInnerPath.fill()
        
        //// upButton
        //// upOuter Drawing
        upOuterPath = UIBezierPath(rect: CGRect(x: 381, y: 0, width: 59, height: 30))
        backgroundColor.setFill()
        upOuterPath.fill()
        
        //// upInner Drawing
        let upInnerPath = UIBezierPath()
        upInnerPath.move(to: CGPoint(x: 395.75, y: 22.5))
        upInnerPath.addLine(to: CGPoint(x: 425.25, y: 22.5))
        upInnerPath.addLine(to: CGPoint(x: 410.5, y: 7.5))
        upInnerPath.addLine(to: CGPoint(x: 410.5, y: 7.5))
        upInnerPath.addLine(to: CGPoint(x: 395.75, y: 22.5))
        upInnerPath.close()
        dark.setFill()
        upInnerPath.fill()
        
        //// downButton
        //// downOuter Drawing
        downOuterPath = UIBezierPath(rect: CGRect(x: 381, y: 30, width: 59, height: 30))
        backgroundColor.setFill()
        downOuterPath.fill()
        
        //// downInner Drawing
        let downInnerPath = UIBezierPath()
        downInnerPath.move(to: CGPoint(x: 410.5, y: 52.5))
        downInnerPath.addLine(to: CGPoint(x: 410.5, y: 52.5))
        downInnerPath.addLine(to: CGPoint(x: 425.25, y: 37.5))
        downInnerPath.addLine(to: CGPoint(x: 395.75, y: 37.5))
        downInnerPath.addLine(to: CGPoint(x: 410.5, y: 52.5))
        downInnerPath.close()
        dark.setFill()
        downInnerPath.fill()

        //// nameLabel Drawing
        let nameLabelRect = CGRect(x: 120, y: 0, width: 320, height: 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left
        
        let nameLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: nameLabelStyle]
        
        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 10, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: fileName).boundingRect(with: CGSize(width: nameLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nameLabelFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: nameLabelInset)
        NSString(string: fileName).draw(in: CGRect(x: nameLabelInset.minX, y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2, width: nameLabelInset.width, height: nameLabelTextHeight), withAttributes: nameLabelFontAttributes)
        context!.restoreGState()
    }
    
    override open func draw(_ rect: CGRect) {
        drawAudioFileLoader(fileName: titles[currentIndex])
    }
}
