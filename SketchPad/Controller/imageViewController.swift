//
//  imageViewController.swift
//  SketchPad
//
//  Created by Vigneshraj Sekar Babu on 7/10/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//

import UIKit

class imageViewController: UIViewController {
    
    var selectedSketch : Sketch? = nil

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
      
    }
    
    
    func initUI() {
        if let sketch = selectedSketch {
            guard var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {fatalError("error with path dir")}
            guard let imageName = sketch.imageName else { fatalError("missing image for cell")}
            path.appendPathComponent(imageName)

            if let imageData = try? Data(contentsOf: path) {
                if let image = UIImage(data: imageData) {
                    
                    imageView.image = image
                    navigationController?.navigationItem.title = sketch.date
                }
            }
        }
    }

    
    @IBAction func editTapped(_ sender: Any) {
        guard let sketch = selectedSketch else {return}
        performSegue(withIdentifier: "editImage", sender: sketch)
    }
    
    @IBAction func actionTapped(_ sender: Any) {
        if let image = imageView.image {
        let shareVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(shareVC, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        if let sketch = selectedSketch {
        context?.delete(sketch)
        }
        do {
            try context?.save()
             navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sketchToEdit = sender as? Sketch else  {fatalError()}
        if segue.identifier == "editImage" {
            if let destinationDrawVC = segue.destination as? DrawViewController {
                destinationDrawVC.editSketch = sketchToEdit
                destinationDrawVC.editFlag = true
                navigationController?.popToRootViewController(animated: false)
                
            }
        }
    }
    


}
