//
//  OrginalImageViewController.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/27/16.
//  Copyright © 2016 BML. All rights reserved.
//

import UIKit

class OrginalImageViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    var photoInfo:PhotoInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let photoInfo = self.photoInfo{
            
            if let orginalImage = photoInfo.orginalImage{
                self.imageView.image = orginalImage
            }
            else{
                self.activityIndicator.startAnimating()
                photoInfo.downLoadPhotoWithSize(size: ImageType.eOrginal, callBack: { [weak self](image, error,photoInfo) in
                    if let weakSelf = self{
                        DispatchQueue.main.async { () -> Void in
                            if(error == nil){
                                weakSelf.imageView.image = image
                            }
                            else{
                                let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                weakSelf.present(alert, animated: true, completion: nil)
                            }
                            weakSelf.activityIndicator.stopAnimating()
                        }
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
