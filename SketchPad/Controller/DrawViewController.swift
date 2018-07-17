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
import ChromaColorPicker

class DrawViewController: UIViewController, ChromaColorPickerDelegate {
    

    
    //var i = 0
    var lastPoint : CGPoint = CGPoint(x: 0, y: 0)
    
    var buttonHidden = false
    var editFlag = false
    var editSketch : Sketch? = nil
    var imageToEdit : UIImage? = nil
    
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
    var selectedEraserWidth : CGFloat = 2
    var eraserSelected : Bool = false
    var selectedLineCap : CGLineCap = .round
    var selectedColor : UIColor = .black
    var lastColor : UIColor = .black
    
    
    //pop over menu config
    var configuration = FTConfiguration.shared
    
    var colorPickerView = UIView()
    var colorPicker = ChromaColorPicker()
        
    let doubleTap = UITapGestureRecognizer()
    let singleTap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if editFlag == false { fillBackground(withColor: .white) }
        else {
            guard let sketchToEdit = editSketch else {fatalError()}
            imageView.image = fetchImageToEdit(sketch: sketchToEdit)
            
        }
        
        imageView.backgroundColor = .white
      
        //pop over menu config setup. for more personlization check github
        configuration.menuRowHeight = 30
        configuration.menuWidth =  90
        configuration.textAlignment = NSTextAlignment.center
        
        colorPickerView = UIView(frame: CGRect(x: 155, y: 812 - 275, width: 200, height: 200))
        colorPickerView.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 0.6)
        colorPickerView.layer.cornerRadius = CGFloat(6)
        view.addSubview(colorPickerView)
        colorPicker = ChromaColorPicker(frame: CGRect(x: 155, y: 812 - 275, width: 200, height: 200))
        view.addSubview(colorPicker)
        colorPicker.delegate = self
 
        colorPickerView.isHidden = true
        colorPicker.isHidden = true
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.addTarget(self, action: #selector(handleDoubleTap))
        colorPaletteButton.addGestureRecognizer(doubleTap)
        
        singleTap.addTarget(self, action: #selector(handleSingleTapInView))
        view.addGestureRecognizer(singleTap)
        
    }
    
    func fetchImageToEdit(sketch : Sketch) -> UIImage {
        guard var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {fatalError("error with path dir")}
        guard let imageName = sketch.imageName else { fatalError("missing image for cell")}
        path.appendPathComponent(imageName)
        
        if let imageData = try? Data(contentsOf: path) {
            if let image = UIImage(data: imageData) {
                
                return image
            }
        }
        return UIImage()
    }
    
    @objc func handleDoubleTap() {
       selectedColor = lastColor
        eraserSelected = false
    }
    
    @objc func handleSingleTapInView() {
        hideColorPicker()
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        guard let image = imageView.image else {
            let alert = UIAlertController(title: "Nothing to Save", message: "draw something to save", preferredStyle: .alert)
            let action = UIAlertAction(title: "Go Back", style: .default) { (action) in
                //
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { fatalError("view context missing")}
        
        guard let imageData  = UIImagePNGRepresentation(image) else { fatalError("cannot convert image to image data")}
        
        guard var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { fatalError()}
        
        let fileName = UUID().uuidString + ".png"
        
        path.appendPathComponent(fileName)
        print(path)
        do {
            try imageData.write(to: path)
        } catch { fatalError("\(error)") }
        
        let sketch = Sketch(context: context)
        sketch.date = getDateAsString()
        sketch.imageName = fileName
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        deleteImageSentForEdit()
        
       
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
        dismiss(animated: true, completion: nil)
      
    }
    
    
    func deleteImageSentForEdit() {
        if editFlag == true {
            let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
            if let sketch = editSketch {
                context?.delete(sketch)
            }
            do {
                try context?.save()
               
            } catch {
                print(error)
            }
        }
    }
    
    func getDateAsString() -> String {
        print(Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMM dd  HH:mm"
        print(dateFormatter.string(from: Date()))
        return dateFormatter.string(from: Date())
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
            colorPickerView.isHidden = true
            colorPicker.isHidden = true
        } else {
            lineButton.isHidden = false
            brushSizeButton.isHidden = false
            colorPaletteButton.isHidden = false
            eraserButton.isHidden = false
            hideButton.setImage(UIImage(named: "hide"), for: .normal)
            trailingConstraintforButtonStack.constant = 15
        }
    }
    
    func hideColorPicker() {
        colorPickerView.isHidden = true
        colorPicker.isHidden = true
    }
    
    @IBAction func setLineCap(_ sender: UIButton) {
        
         hideColorPicker()
        eraserSelected = false
        
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
            // TODO: no cancel. why do i need this?
            print("cancel")
        }
    }
    
    @IBAction func setBrushTapped(_ sender: UIButton) {
         hideColorPicker()
        eraserSelected = false
        let brushSizes : [String] = ["Fill","50", "20", "10", "8", "6", "4", "2"]
        
        FTPopOverMenu.showForSender(sender: sender, with: brushSizes,  done: { (selectedIndex) in
            if brushSizes[selectedIndex] == "Fill" {
                self.fillBackground(withColor: self.selectedColor)
            } else if let width = NumberFormatter().number(from: brushSizes[selectedIndex]) {
                self.selectedBrushWidth = CGFloat(truncating: width)
            }
            
        }){
        }
        
    }
    
    @IBAction func setColorTapped(_ sender: UIButton) {
        eraserSelected = false
        colorPickerView.isHidden = false
        colorPicker.isHidden = false
    }
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        selectedColor = color
        lastColor = selectedColor
        hideColorPicker()
    }
    
    @IBAction func eraserTapped(_ sender: UIButton) {
         hideColorPicker()
        eraserSelected = true
        selectedColor = .white
        let sizes = ["big", "medium", "small"]
        FTPopOverMenu.showForSender(sender: sender, with: sizes,  done: { (selectedIndex) in
            
            switch sizes[selectedIndex] {
            case "big":
                self.selectedEraserWidth = 50
            case "medium":
                self.selectedEraserWidth = 20
            case "small":
                self.selectedEraserWidth = 10
            default:
                self.selectedEraserWidth = 10
            }
        }) {
        }
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // print("touch began")
        stackViewForButtons.isHidden = true
        hideColorPicker()
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
        //print("touch ended")
        //        i = 0
        if let endPoint = touches.first?.location(in: imageView){
            drawBetweenPoints(startPoint: lastPoint, endPoint: endPoint)
        }
        stackViewForButtons.isHidden = false
    }
    
    func drawBetweenPoints(startPoint : CGPoint, endPoint : CGPoint) {
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
        
        
        if let context = UIGraphicsGetCurrentContext() {
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            context.setLineWidth(eraserSelected ? selectedEraserWidth : selectedBrushWidth)
            context.setLineCap(selectedLineCap)
            context.setStrokeColor(selectedColor.cgColor)
            context.strokePath()
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    
    func whiteBackground() {
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
       context.fill(CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    func fillBackground(withColor color : UIColor) {
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    //not used in the application as the images were required as assets with string names to be passed. TODO:
    func getColoredImages(colors : [String]) -> [UIImage] {
        
        var imageArray : [UIImage] = []
        for color in colors {
            switch color {
            case "black":
                imageArray.append(getImageWithColor(color: .black))
            case "blue":
                imageArray.append(getImageWithColor(color: .blue))
            case "red":
                imageArray.append(getImageWithColor(color: .red))
            case "green":
                imageArray.append(getImageWithColor(color: .green))
            case "cyan":
                imageArray.append(getImageWithColor(color: .cyan))
            case "gray":
                imageArray.append(getImageWithColor(color: .gray))
            case "yellow":
                imageArray.append(getImageWithColor(color: .yellow))
            default:
                imageArray.append(getImageWithColor(color: .black))
            }
        }
        
        return imageArray
        
    }
    
    //https://stackoverflow.com/questions/26542035/create-uiimage-with-solid-color-in-swift
    func getImageWithColor(color: UIColor) -> UIImage {
        let fixedSize = CGSize(width: 100.0, height: 100.0)
        let rect = CGRect(x: 0, y: 0, width: fixedSize.width, height: fixedSize.height)
        UIGraphicsBeginImageContextWithOptions(fixedSize, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}





