//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Marco Guevara on 16/11/22.
//

import UIKit

private let reuseIdentifier = "MemeCollectionViewCell"

class MemeCollectionViewController: UICollectionViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = false
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView!.reloadData()
    }

    @IBAction func newMemeAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "MemeEditorSegue", sender: nil)
    }


    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
    
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        cell.imageView?.image = meme.memedImage
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {

        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController

        detailController.meme = memes[(indexPath as NSIndexPath).row]

        navigationController!.pushViewController(detailController, animated: true)

    }


}
