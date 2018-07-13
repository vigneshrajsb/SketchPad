//
//  ViewController.swift
//  SketchPad
//
//  Created by Vigneshraj Sekar Babu on 7/10/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//
// App Icons made by Freepik from www.flaticon.com is licensed by CC 3.0 BY

// Pop up menu from https://github.com/liufengting/FTPopOverMenu_Swift


import UIKit
import FTPopOverMenu_Swift

class DrawViewController: UIViewController {
    //var i = 0
    var lastPoint : CGPoint = CGPoint(x: 0, y: 0)
    
    var buttonHidden = false
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var brushSizeButton: UIButton!
    @IBOutlet weak var colorPaletteButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var stackViewForButtons: UIStackView!
    @IBOutlet weak var trailingConstraintforButtonStack: NSLayoutConstraint!
    
    //MARK: - Drawing Properties
    var selectedBrushWidth : CGFloat = 2
    var selectedLineCap : CGLineCap = .round
    var selectedColor : UIColor = .black
    
    
    //pop over menu config
    var configuration = FTConfiguration.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
            //pop over menu config setup
        configuration.menuRowHeight = 30
        configuration.menuWidth =  75
        //    configuration.textColor = ...
        //    configuration.textFont = ...
        //    configuration.tintColor = ...
        //    configuration.borderColor = ...
        //    configuration.borderWidth = ...
        configuration.textAlignment = NSTextAlignment.center
        //configuration.ignoreImageOriginalColor = ...;
    }

 

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func hideTapped(_ sender: Any) {
        buttonHidden = !buttonHidden
        if buttonHidden {
        lineButton.isHidden = true
        brushSizeButton.isHidden = true
        colorPaletteButton.isHidden = true
        eraserButton.isHidden = true
        hideButton.setImage(UIImage(named: "show"), for: .normal)
        trailingConstraintforButtonStack.constant = 310
        } else {
            lineButton.isHidden = false
            brushSizeButton.isHidden = false
            colorPaletteButton.isHidden = false
            eraserButton.isHidden = false
            hideButton.setImage(UIImage(named: "hide"), for: .normal)
            trailingConstraintforButtonStack.constant = 15
        }
    }
    
    
    @IBAction func setLineCap(_ sender: UIButton) {
        
        FTPopOverMenu.showForSender(sender: sender, with: ["butt", "round", "square"],  done: { (selectedIndex) in
            
            switch selectedIndex {
            case 0:
                self.selectedLineCap = CGLineCap.butt
            case 1:
                self.selectedLineCap = CGLineCap.round
            case 2:
                self.selectedLineCap = CGLineCap.square
            default:
                self.selectedLineCap = CGLineCap.round
            }
        }) {
            // no cancel. why do i need this?
            print("cancel")
        }
    }
    
    @IBAction func setBrushTapped(_ sender: UIButton) {
        let brushSizes : [String] = ["50", "20", "10", "8", "6", "4", "2"]
        
        FTPopOverMenu.showForSender(sender: sender, with: brushSizes,  done: { (selectedIndex) in
            
            if let width = NumberFormatter().number(from: brushSizes[selectedIndex]) {
                self.selectedBrushWidth = CGFloat(truncating: width)
            }
            
        }){
        // no cancel. why do i need this?
        print("cancel")
    }

    }
    
    @IBAction func setColorTapped(_ sender: UIButton) {
        let colors = ["black", "blue", "red", "green", "cyan", "grey", "yellow"]
        FTPopOverMenu.showForSender(sender: sender, with: colors, done: { (selectedIndex) in
            switch colors[selectedIndex] {
            case "black":
                self.selectedColor = .black
            case "blue":
               self.selectedColor = .blue
            case "red":
                self.selectedColor = .red
            case "green":
                self.selectedColor = .green
            case "cyan":
                self.selectedColor = .cyan
            case "grey":
                self.selectedColor = .gray
            case "yellow":
                self.selectedColor = .yellow
            default:
                self.selectedColor = .black
            }
        }){
            // no cancel. why do i need this?
            print("cancel")
        }
        
    }
    
    @IBAction func eraserTapped(_ sender: UIButton) {
        selectedColor = .white
        let sizes = ["big", "medium", "small"]
        FTPopOverMenu.showForSender(sender: sender, with: sizes,  done: { (selectedIndex) in
            
            switch sizes[selectedIndex] {
            case "big":
                self.selectedBrushWidth = 50
            case "medium":
                self.selectedBrushWidth = 20
            case "small":
                self.selectedBrushWidth = 10
            default:
                self.selectedBrushWidth = 10
            }
        }) {
            // no cancel. why do i need this?
            print("cancel")
        }
      
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("touch began")
        if let touchPoint = touches.first?.location(in: imageView) {
            lastPoint = touchPoint
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("moved \(i) times")
//        i += 1
        if let movePoint = touches.first?.location(in: imageView) {
            drawBetweenPoints(startPoint: lastPoint, endPoint: movePoint)
            lastPoint = movePoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touch ended")
//        i = 0
        if let endPoint = touches.first?.location(in: imageView){
            drawBetweenPoints(startPoint: lastPoint, endPoint: endPoint)
        }
    }
    
    func drawBetweenPoints(startPoint : CGPoint, endPoint : CGPoint) {
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
        
        if let context = UIGraphicsGetCurrentContext() {
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            context.setLineWidth(selectedBrushWidth)
            context.setLineCap(selectedLineCap)
            context.setStrokeColor(selectedColor.cgColor)
            context.strokePath()
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        
        
    }
    
}




