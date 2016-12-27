//
//  ViewController.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/20/16.
//  Copyright © 2016 BML. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    let defaut_Page_Size = 10

    private var pageInfo = PageInfo(pageNumber: 1,pageSize: 10)
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: -50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    private var datasource:[PhotoInfo] = []
    private var syncing = false
    

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate let itemsPerRow: CGFloat = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if Oauth.default.user_Name == nil{
            self.navigationController?.performSegue(withIdentifier: "ShowLoginView", sender: nil)
        }
        self.collectionView.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let user_name = Oauth.default.user_Name{
            self.title = user_name
            self.fetchPublicPhotosFromFlickrWithPageInfo(self.pageInfo)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func fetchPublicPhotosFromFlickrWithPageInfo(_ pageInfo:PageInfo) -> Void {
        
        self.activityIndicator.startAnimating()
        self.syncing = true
        Flickr.getPublicPhotos(Oauth.default, pageInfo, callback:{ (error,results) -> Void in
            DispatchQueue.main.async { () -> Void in
                if(error == nil){
                    
                    self.datasource.append(contentsOf: results!)
                    self.collectionView.reloadData()
                }
                else{
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                self.activityIndicator.stopAnimating()
                self.syncing = false
            }
        })
    }

    // MARK: - UICollectionViewDataSource protocol

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCell
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let photoInfo = datasource[indexPath.row]
        
        if let image = photoInfo.thumbnail{
            cell.imageView.image = image
        }
        else{
            cell.imageView.image = nil
            cell.activityIndicator.startAnimating()
            photoInfo.downLoadPhotoWithSize(callBack: { (image, error, photoInfo) in
                DispatchQueue.main.async { () -> Void in
                    if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell{
                        cell.imageView.image = photoInfo.thumbnail
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        let photoInfo = datasource[indexPath.row]
        self.performSegue(withIdentifier: "ShowOrginalImage", sender: photoInfo)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout protocol
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }


    //MARK: ScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let offset = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height))
        
        if offset >= 0 && !syncing && datasource.count > 0{
            let newPageNumber = Utility.calculatePageNumberFor(pageSize: defaut_Page_Size, withArrayCount: datasource.count)
            self.pageInfo.pageNumber = newPageNumber
            self.fetchPublicPhotosFromFlickrWithPageInfo(self.pageInfo)
        }
    }

    override func viewDidLayoutSubviews() {
        self.collectionView.reloadData()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "ShowOrginalImage" && (sender as? PhotoInfo) != nil){
            let controller = segue.destination as! OrginalImageViewController
            controller.photoInfo = sender as? PhotoInfo
        }
    }

}

