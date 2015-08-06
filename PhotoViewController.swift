//
//  PhotoViewController.swift
//  ImageFilters
//
//  Created by Josh Nagel on 4/6/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

import UIKit
import CoreImage
import Social

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GalleryImageDelegate {
  
  //MARK:
  //MARK: Constants, Variables, and Outlets
  
  let optionsAlertController = UIAlertController(title: "Options", message: nil, preferredStyle: .ActionSheet)
  var messageAlertController = UIAlertController(title: "Add Photo Details", message: nil, preferredStyle: .Alert)
  
  @IBOutlet weak var photoButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var constraintCollectionViewBottom: NSLayoutConstraint!
  @IBOutlet weak var primaryImageView: UIImageView!
  
  @IBOutlet weak var constraintImageLeading: NSLayoutConstraint!
  @IBOutlet weak var constrantImageTrailing: NSLayoutConstraint!
  @IBOutlet weak var constraintImageTop: NSLayoutConstraint!
  @IBOutlet weak var constraintImageBottom: NSLayoutConstraint!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var constraintStatusMessageHeight: NSLayoutConstraint!
  @IBOutlet weak var progressView: UIProgressView!
  
  let constraintcollectionViewBottomInFilter: CGFloat = 8
  let collectionViewHeight: CGFloat = 75
  var originalImageConstraintTopLeadingTrailing: CGFloat = 0
  var originalImageConstraintBottom: CGFloat = 0
  let constraintBuffer: CGFloat = 50
  
  let imageToUploadSize = CGSize(width: 600, height: 600)
  let animationDuration = 0.2
  let thumbnailImageSize = CGSize(width: 75, height: 75)
  var currentThumbnailImage: UIImage!
  var originalThumbnailImage : UIImage!
  var currentTitle: String?
  var currentMessage: String?
  
  let filters = [
      FilterService.photoEffectTransferFilter,
      FilterService.colorInvertFilter,
      FilterService.photoEffectChromeFilter,
      FilterService.photoEffectInstantFilter,
      FilterService.vignetteFilter,
      FilterService.photoEffectFadeFilter,
      FilterService.sepiaToneFilter,
      FilterService.gaussianBlurFilter,
      FilterService.pinchDistortionFilter,
      FilterService.dotScreenFilter,
      FilterService.lineScreenFilter,
      FilterService.pixellateFilter,
      FilterService.vibranceFilter,
      FilterService.colorMatrixFilter,
      FilterService.colorPosterizeFilter,
      FilterService.photoEffectNoirFilter,
      FilterService.greenMonochromeFilter,
      FilterService.blueMonochromeFilter,
      FilterService.hueAdjustFilter
  ]
  var context: CIContext!
  
  
  var originalImage: UIImage! {
    didSet {
      self.currentImage = self.originalImage
    }
  }
  var currentImage : UIImage! {
    didSet {
      self.primaryImageView.image = self.currentImage
      self.originalThumbnailImage = ImageResizer.resizeImage(self.currentImage, size: self.thumbnailImageSize)
      self.collectionView.reloadData()
    }
  }
  
  //MARK:
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let socialBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "socialShare")
    self.navigationItem.rightBarButtonItem = socialBarButton
    let messageBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "addMessage")
    self.navigationItem.leftBarButtonItem = messageBarButton
    
    let topBarImage = UIImage(named: "TopBar")
    let bottomBarImage = UIImage(named: "BottomBar")
    self.navigationController!.navigationBar.setBackgroundImage(topBarImage, forBarMetrics: .Default)
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
    
    self.tabBarController!.tabBar.backgroundImage = bottomBarImage
    self.tabBarController!.tabBar.tintColor = UIColor.whiteColor()

    self.originalImage = UIImage(named: "photo3.jpg")
    self.currentImage = self.originalImage
    
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.context = CIContext(EAGLContext: eaglContext, options: options)
    
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    self.constraintStatusMessageHeight.constant = 0
    self.statusLabel.alpha = 0
    self.progressView.alpha = 0
    
    self.originalImageConstraintBottom = self.constraintCollectionViewBottom.constant
    self.originalImageConstraintTopLeadingTrailing = self.constraintImageLeading.constant
    self.constraintCollectionViewBottom.constant = -tabBarController!.tabBar.frame.height - collectionViewHeight
    self.constraintImageLeading.constant = self.originalImageConstraintTopLeadingTrailing
    self.constrantImageTrailing.constant = self.originalImageConstraintTopLeadingTrailing
    self.constraintImageTop.constant = self.originalImageConstraintTopLeadingTrailing
    self.constraintImageBottom.constant = self.originalImageConstraintBottom
    
    //MARK: ViewDidLoad - UIAlertActions
    
    self.optionsAlertController.view.tintColor = UIColor(red: 0.034, green: 0.199, blue: 0.410, alpha: 1.000)
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      let cameraAction = UIAlertAction(title: "Take A Picture", style: .Default) { [weak self] (alert) -> Void in
        if self != nil {
          var imagePickerController = UIImagePickerController()
          imagePickerController.delegate = self!
          imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
          imagePickerController.allowsEditing = true
          self!.presentViewController(imagePickerController, animated: true, completion: nil)
        }
      }
      self.optionsAlertController.addAction(cameraAction)
    }
    
    let filterAction = UIAlertAction(title: "Add Filter", style: .Default) { [weak self] (alert) -> Void in
      if self != nil {
        self!.enterFilterMode()
      }
    }
    self.optionsAlertController.addAction(filterAction)
    
    let uploadAction = UIAlertAction(title: "Upload to My Timeline", style: .Default) { [weak self] (alert) -> Void in
      if self != nil {
        self!.progressView.alpha = 1
        UIView.animateWithDuration(2, animations: { () -> Void in
          self!.progressView.setProgress(0.7, animated: true)
        })
        ParseService.uploadImageInfo(self!.primaryImageView.image!, title: self!.currentTitle, message: self!.currentMessage, size: self!.imageToUploadSize, completionHandler: { (success, error) -> Void in
          if error != nil {
            self!.statusLabel.text = "An Error Occured"
          } else {
            self!.currentMessage = nil
            self!.currentTitle = nil
            
            UIView.animateWithDuration(1.0, animations: { () -> Void in
              self!.progressView.setProgress(1.0, animated: true)
            }, completion: { (finished) -> Void in
              self!.constraintStatusMessageHeight.constant = 40;
              UIView.animateWithDuration(self!.animationDuration, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self!.view.layoutIfNeeded()
                self!.statusLabel.alpha = 1
                }, completion: { (finished) -> Void in
                  self!.progressView.alpha = 0
                  self!.progressView.setProgress(0, animated: false)
                  self!.constraintStatusMessageHeight.constant = 0;
                  UIView.animateWithDuration(self!.animationDuration, delay: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self!.view.layoutIfNeeded()
                    self?.statusLabel.alpha = 0
                    }, completion: nil)
              })
            })
          }
        })
      }
    }
    self.optionsAlertController.addAction(uploadAction)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    self.optionsAlertController.addAction(cancelAction)
    
    let galleryAction = UIAlertAction(title: "Show Gallery", style: .Default) { [weak self] (alert) -> Void in
      if self != nil {
        self!.performSegueWithIdentifier("ShowGallery", sender: self)
      }
    }
    self.optionsAlertController.addAction(galleryAction)
    
    let saveMessageAction = UIAlertAction(title: "Save", style: .Default) { [weak self] (action: UIAlertAction!) -> Void in
      if self != nil {
        let titleField = self!.messageAlertController.textFields![0] as! UITextField
        let messageField = self!.messageAlertController.textFields![1] as! UITextField
        self!.currentTitle = titleField.text
        self!.currentMessage = messageField.text
      }
    }
    let cancelMessageAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
    self.messageAlertController.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
      textField.placeholder = "Enter a title"
    }
    self.messageAlertController.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
      textField.placeholder = "Enter a message"
    }
    self.messageAlertController.addAction(saveMessageAction)
    self.messageAlertController.addAction(cancelMessageAction)

  }
  
  func enterFilterMode() {
    self.constraintImageLeading.constant += self.constraintBuffer
    self.constrantImageTrailing.constant += self.constraintBuffer
    self.constraintImageTop.constant += self.constraintBuffer
    self.constraintImageBottom.constant += self.constraintBuffer
    self.constraintCollectionViewBottom.constant = self.constraintcollectionViewBottomInFilter
    self.photoButton.enabled = false
    self.photoButton.hidden = true
    self.view.backgroundColor = UIColor.whiteColor()
    
    UIView.animateWithDuration(animationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
    let leftBarButton = UIBarButtonItem(title: "Undo", style: UIBarButtonItemStyle.Plain, target: self, action: "undoFilters")
    leftBarButton.tintColor = UIColor.redColor()
    self.navigationItem.leftBarButtonItem = leftBarButton
  }
  
  func exitFilterMode() {
    self.constraintImageLeading.constant = self.originalImageConstraintTopLeadingTrailing
    self.constrantImageTrailing.constant = self.originalImageConstraintTopLeadingTrailing
    self.constraintImageTop.constant = self.originalImageConstraintTopLeadingTrailing
    self.constraintImageBottom.constant = self.originalImageConstraintBottom
    self.constraintCollectionViewBottom.constant = -tabBarController!.tabBar.frame.height - collectionViewHeight
    self.photoButton.enabled = true
    self.photoButton.hidden = false
    self.view.backgroundColor = UIColor.darkGrayColor()
    
    UIView.animateWithDuration(animationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "socialShare")
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "addMessage")
  }
  
  func undoFilters() {
    self.currentImage = self.originalImage
  }
  
  func addMessage() {
    self.messageAlertController.view.tintColor = UIColor(red: 0.034, green: 0.199, blue: 0.410, alpha: 1.000)
    let titleTextField = self.messageAlertController.textFields![0] as! UITextField
    let messageTextField = self.messageAlertController.textFields![1] as! UITextField
    titleTextField.text = self.currentTitle
    messageTextField.text = self.currentMessage
    self.presentViewController(self.messageAlertController, animated: true) {[weak self] () -> Void in
    }
  }
  
  @IBAction func photoButtonPressed(sender: UIButton) {
    if let popoverController = self.optionsAlertController.popoverPresentationController {
      popoverController.sourceView = sender
      popoverController.sourceRect = sender.bounds
    }
    self.presentViewController(self.optionsAlertController, animated: true, completion: nil)
  }
 
  func socialShare() {
    var sharingItems = [AnyObject]()
    sharingItems.append(self.currentImage)
    if let title = self.currentTitle {
      sharingItems.append(title)
    }
    if let message = self.currentMessage {
      sharingItems.append(" - \(message)")
    }
    
    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
    activityViewController.view.tintColor = UIColor(red: 0.034, green: 0.199, blue: 0.410, alpha: 1.000)
    
    activityViewController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
    activityViewController.popoverPresentationController?.sourceView = self.view
    self.presentViewController(activityViewController, animated: true, completion: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowGallery" {
      let destinationController = segue.destinationViewController as! GalleryViewController
      destinationController.imageSizeForPrimaryView = self.primaryImageView.frame.size
      destinationController.delegate = self
    }
  }
  
  //MARK:
  //MARK: GalleryViewDelegate
  
  func imageForPrimaryView(image: UIImage) {
    self.originalImage = image
    
  }
  
  //MARK:
  //MARK: UIImagePickerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let photo = info[UIImagePickerControllerEditedImage] as? UIImage {
      self.originalImage = photo
    }
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK:
  //MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.filters.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
    let filter = self.filters[indexPath.row]
    cell.imageView.image = filter(self.originalThumbnailImage, context: self.context)
    return cell
  }
  
  //MARK:
  //MARK: UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let filter = self.filters[indexPath.row]
    self.currentImage = filter(self.currentImage, context: self.context)
  }
}
