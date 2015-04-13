//
//  TimelineViewController.swift
//  ImageFilters
//
//  Created by Josh Nagel on 4/8/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DeletedTimelineRecordDelegate {

  var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet var collectionView: UICollectionView!
  
  var timelineImageInfo = [TimelineImageInfo]()
  let refreshControl = UIRefreshControl()
  var lastRefresh = NSDate()
  var selectedImage: TimelineImageInfo?
  var newSizeForCells: CGSize!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.userInteractionEnabled = true
    self.flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    self.newSizeForCells = self.flowLayout.itemSize
    
    let topBarImage = UIImage(named: "TopBar")
    let bottomBarImage = UIImage(named: "BottomBar")
    self.navigationController!.navigationBar.setBackgroundImage(topBarImage, forBarMetrics: .Default)
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
    
    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    self.collectionView.addSubview(refreshControl)
    
    var pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchOccurred:")
    self.collectionView.addGestureRecognizer(pinchRecognizer)
    
    var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
    self.collectionView.addGestureRecognizer(pinchRecognizer)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if !self.timelineImageInfo.isEmpty {
      self.fetchTimelinePosts(self.lastRefresh)
    } else {
      self.fetchTimelinePosts(nil)
    }
  }
  
  //MARK:
  //MARK: Custom methods
  
  func refresh(sender: AnyObject) {
    self.refreshControl.beginRefreshing()
    self.fetchTimelinePosts(self.lastRefresh)
    self.refreshControl.endRefreshing()
  }
  
  func fetchTimelinePosts(date: NSDate?) {
    ParseService.fetchPosts(date) { [weak self] (objects, error) -> Void in
      if self != nil {
        if error != nil {
          println(error!.description)
        } else {
          for (index, object) in enumerate(objects!) {
            let objectId = object.objectId
            let imageFile = object["imageFile"] as! PFFile
            let message = object["message"] as? String
            let location = object["location"] as? String
            var imageInfo = TimelineImageInfo()
            imageInfo.objectId = objectId
            imageInfo.file = imageFile
            imageInfo.message = message
            imageInfo.location = location
            if date != nil {
              self!.timelineImageInfo.insert(imageInfo, atIndex: 0)
              self!.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
            } else {
              self!.timelineImageInfo.append(imageInfo)
              self!.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self!.timelineImageInfo.count - 1, inSection: 0)])
            }
          }
        }
        self!.lastRefresh = NSDate()
        self!.refreshControl.endRefreshing()
        self!.collectionView.userInteractionEnabled = true
      }
    }
  }
  
  func pinchOccurred(sender: UIPinchGestureRecognizer) {
    var maxSizeForCell = self.collectionView.frame.size
    let minSizeForCell = CGSize(width: 50, height: 50)
    let oldSize = self.flowLayout.itemSize
    if sender.state == UIGestureRecognizerState.Changed {
      if (oldSize.width >= maxSizeForCell.width && sender.scale >= 1) || (oldSize.width <= minSizeForCell.width && sender.scale <= 1) {
        return
      } else {
        var newScale: CGFloat = sender.scale
        if sender.scale > 1 {
          if sender.scale >= 1.50 {
            newScale = 1.5
          } else if sender.scale >= 1.25 {
            newScale = 1.25
          }
        } else if sender.scale < 1{
          if sender.scale <= 0.50 {
            newScale = 0.50
          } else if sender.scale <= 0.25 {
            newScale = 0.25
          }
        }
        self.newSizeForCells = CGSize(width: oldSize.width * newScale, height: oldSize.width * newScale)
        if self.newSizeForCells.width >= maxSizeForCell.width {
          self.newSizeForCells = CGSize(width: maxSizeForCell.width, height: maxSizeForCell.width)
        } else if self.newSizeForCells.width <= minSizeForCell.height {
          self.newSizeForCells = minSizeForCell
        }
        self.collectionView.performBatchUpdates({ [weak self] () -> Void in
          if self != nil {
            self!.flowLayout.itemSize = self!.newSizeForCells
          }
          }, completion: nil)
      }
    } else if sender.state == UIGestureRecognizerState.Ended {
      self.collectionView.performBatchUpdates({ [weak self] () -> Void in
        if self != nil {
          self!.collectionView.reloadSections(NSIndexSet(index: 0))
        }
      }, completion: nil)
    }
  }
  
  //MARK:
  //MARK: DeletedTimelineRecordDelegate
  
  func removeCellFromCollectionView(objectId: String) -> Void {
    for (index, info) in enumerate(timelineImageInfo) {
      if info.objectId == objectId {
        self.timelineImageInfo.removeAtIndex(index)
        self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
      }
    }
  }
  
  //MARK:
  //MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.timelineImageInfo.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimelineCell", forIndexPath: indexPath) as! TimelineCollectionViewCell
    let info = timelineImageInfo[indexPath.row]
    cell.configureCell(info)
    return cell
  }
  
  //MARK:
  //MARK: UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.selectedImage = self.timelineImageInfo[indexPath.row]
    self.performSegueWithIdentifier("ShowTimelineInfo", sender: self)
  }
  
  //MARK:
  //MARK: Prepare for segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowTimelineInfo" {
      let destinationController = segue.destinationViewController as! TimelineInfoViewController
      destinationController.timelineImageInfo = self.selectedImage
      destinationController.delegate = self
    }
  }
}
