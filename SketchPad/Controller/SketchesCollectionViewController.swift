//
//  SketchesCollectionViewController.swift
//  SketchPad
//
//  Created by Vigneshraj Sekar Babu on 7/10/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class SketchesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var sketches : [Sketch]?
    
 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

        // Register cell classes
       // self.collectionView!.register(ImageViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

       
    }

    override func viewWillAppear(_ animated: Bool) {
         fetchdata()
        collectionView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView?.reloadData()
    }
    
    func fetchdata() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { fatalError("context not available")}
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sketch")
        
        do {
            if let fetchedSketches = try context.fetch(fetchRequest) as? [Sketch]{
                sketches = fetchedSketches.reversed()
//                for item in fetchedSketches {
//                    guard let date = item.date else {return}
//                    guard let imageName = item.imageName else { return}
//                }
            }
            
        } catch {
            fatalError("Error Fetching context :  \(error)")
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let sketches = sketches {
        return sketches.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageViewCell {
            
            guard var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {fatalError("error with path dir")}
            
            if  let sketch = sketches?[indexPath.row] {
                guard let imageName = sketch.imageName else { fatalError("missing image for cell")}
                path.appendPathComponent(imageName)
                //print("\(path)")
                if let imageData = try? Data(contentsOf: path) {
                    if let image = UIImage(data: imageData) {
                        
                        cell.imageView.image = image
                        cell.dateLabel.text =  sketch.date
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.safeAreaLayoutGuide.layoutFrame.width / 3.2
        let height = width * 2
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        if let sketch = sketches?[indexPath.row] {
        performSegue(withIdentifier: "gotToImage", sender: sketch)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        
        if segue.identifier == "gotToImage" {
            if let destinationVC = segue.destination as? imageViewController {
                if let sketch = sender as? Sketch {
                destinationVC.selectedSketch = sketch
                }
            }
            
        }
    }
    
}
