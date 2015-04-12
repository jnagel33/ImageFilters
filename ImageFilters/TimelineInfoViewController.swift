//
//  TimelineInfoViewController.swift
//  ImageFilters
//
//  Created by Josh Nagel on 4/11/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

import UIKit

protocol DeletedTimelineRecordDelegate : class {
  func removeCellFromCollectionView(objectId: String) -> Void
}

class TimelineInfoViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  
  var timelineImageInfo: TimelineImageInfo!
  var delegate: DeletedTimelineRecordDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let trashBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "removeUpload")
    self.navigationItem.rightBarButtonItem = trashBarButton
    
    
    if let image = timelineImageInfo.image {
      self.imageView.image = ImageResizer.resizeImage(image, size: self.imageView.frame.size)
    }
    self.messageLabel.text = nil
    self.locationLabel.text = nil
    if let messageText = timelineImageInfo.message {
      self.messageLabel.text = messageText
    }
    if let locationText = timelineImageInfo.location {
      self.locationLabel.text = locationText
    }
  }
  
  func removeUpload() {
    let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this image?", preferredStyle: .Alert)
    let yesAction = UIAlertAction(title: "Yes", style: .Destructive) { [weak self] (alert) -> Void in
      if self != nil {
        ParseService.deleteImageRecord(self!.timelineImageInfo.objectId, completionHandler: { (success, error) -> Void in
          if error != nil {
            //handle error
          } else {
        self!.delegate!.removeCellFromCollectionView(self!.timelineImageInfo.objectId)
        self!.navigationController?.popToRootViewControllerAnimated(true)
          }
        })
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(yesAction)
    alertController.addAction(cancelAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
}
