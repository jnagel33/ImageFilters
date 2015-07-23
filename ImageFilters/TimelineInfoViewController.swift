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

  @IBOutlet weak var imageButton: UIButton!
  @IBOutlet weak var messageButton: UIButton!
  
  var timelineImageInfo: TimelineImageInfo!
  var delegate: DeletedTimelineRecordDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let topBarImage = UIImage(named: "TopBar")
    self.navigationController!.navigationBar.setBackgroundImage(topBarImage, forBarMetrics: .Default)
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
    
    let trashBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "removeUpload")
    self.navigationItem.rightBarButtonItem = trashBarButton
    
    let stopBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "dismissVC")
    self.navigationItem.leftBarButtonItem = stopBarButton
    
    
    if let image = timelineImageInfo.image {
      self.imageButton.setBackgroundImage(ImageResizer.resizeImage(image, size: self.imageButton.frame.size), forState: UIControlState.Normal)
    }
    if let titleText = timelineImageInfo.title {
      self.title = titleText
    }
    if let messageText = timelineImageInfo.message {
      self.messageButton.setTitle(messageText, forState: UIControlState.Normal)
    }
  }
  
  func removeUpload() {
    let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this image?", preferredStyle: .Alert)
    alertController.view.tintColor = UIColor(red: 0.034, green: 0.199, blue: 0.410, alpha: 1.000)
    
    let yesAction = UIAlertAction(title: "Yes", style: .Destructive) { [weak self] (alert) -> Void in
      if self != nil {
        ParseService.deleteImageRecord(self!.timelineImageInfo.objectId, completionHandler: { (success, error) -> Void in
          if error != nil {
            let alert = UIAlertController(title: "Failed to delete record", message: "Please try again", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: { (alert) -> Void in
              self!.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(okAction)
            self!.presentViewController(alert, animated: true, completion: nil)
          }
        })
        self!.dismissViewControllerAnimated(true, completion: nil)
        self!.delegate!.removeCellFromCollectionView(self!.timelineImageInfo.objectId)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(yesAction)
    alertController.addAction(cancelAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  func dismissVC() {
    self .dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func messageButtonPressed(sender: UIButton) {
  var messageAlertController = UIAlertController(title: "Add Photo Details", message: nil, preferredStyle: .Alert)
    let saveMessageAction = UIAlertAction(title: "Save", style: .Default) { [weak self] (action: UIAlertAction!) -> Void in
      if self != nil {
        let titleField = messageAlertController.textFields![0] as! UITextField
        let messageField = messageAlertController.textFields![1] as! UITextField
        self!.timelineImageInfo.title = titleField.text
        self!.timelineImageInfo.message = messageField.text
        
        if let title = self!.timelineImageInfo.title {
          self!.title = title
        }
        if let message = self!.timelineImageInfo.message {
          self!.messageButton.setTitle(message, forState: UIControlState.Normal)
        }
        ParseService.updateImageRecord(self!.timelineImageInfo, completionHandler: { (success, error) -> Void in
          
        })
      }
    }
    let cancelMessageAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
    messageAlertController.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
      textField.placeholder = "Enter a title"
    }
    messageAlertController.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
      textField.placeholder = "Enter a message"
    }
    messageAlertController.addAction(saveMessageAction)
    messageAlertController.addAction(cancelMessageAction)

    messageAlertController.view.tintColor = UIColor(red: 0.034, green: 0.199, blue: 0.410, alpha: 1.000)
    let titleTextField = messageAlertController.textFields![0] as! UITextField
    let messageTextField = messageAlertController.textFields![1] as! UITextField
    titleTextField.text = self.timelineImageInfo.title
    messageTextField.text = self.timelineImageInfo.message
    self.presentViewController(messageAlertController, animated: true) {[weak self] () -> Void in
    }
  }
  
  @IBAction func shareImagePressed(sender: UIButton) {
    var sharingItems = [AnyObject]()
    sharingItems.append(self.timelineImageInfo.image!)
    if let title = self.timelineImageInfo.title {
      sharingItems.append(title)
    }
    if let message = self.timelineImageInfo.message {
      sharingItems.append(" - \(message)")
    }
    
    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
    activityViewController.view.tintColor = UIColor(red: 0.034, green: 0.199, blue: 0.410, alpha: 1.000)
    self.presentViewController(activityViewController, animated: true, completion: nil)
  }
  
}
