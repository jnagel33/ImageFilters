//
//  GalleryViewController.swift
//  ImageFilters
//
//  Created by Josh Nagel on 4/9/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

import UIKit
import Photos

protocol GalleryImageDelegate : class {
  func imageForPrimaryView(image: UIImage) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet var collectionView: UICollectionView!
  
  var assets = PHFetchResult()
  let manager = PHCachingImageManager()
  var delegate: GalleryImageDelegate?
  var imageSizeForPrimaryView: CGSize!
  var galleryImages: [UIImage] = [UIImage]()
  var newSizeForCells: CGSize!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    self.newSizeForCells = self.flowLayout.itemSize
    
    self.assets = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
    
    var pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchOccurred:")
    self.collectionView.addGestureRecognizer(pinchRecognizer)
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
  //MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return assets.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryCell", forIndexPath: indexPath) as!
    GalleryCollectionViewCell
    cell.tag++
    let tag = cell.tag
    cell.imageView.image = nil
    
    if tag == cell.tag {
      let asset = self.assets[indexPath.row] as! PHAsset
      if !self.galleryImages.isEmpty && self.galleryImages.count > indexPath.row {
        let resizedImage = ImageResizer.resizeImage(self.galleryImages[indexPath.row], size: self.flowLayout.itemSize)
        cell.imageView.image = resizedImage
      } else {
        let image = self.manager.requestImageForAsset(asset, targetSize: self.flowLayout.itemSize, contentMode: .AspectFill, options: nil) { [weak self] (image, info) -> Void in
          if self != nil {
            cell.imageView.image = image
          }
        }
      }
    }
    return cell
  }
  
  //MARK:
  //MARK: UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let asset = self.assets[indexPath.row] as! PHAsset
    var options = PHImageRequestOptions()
    options.networkAccessAllowed = true
    let image = self.manager.requestImageForAsset(asset, targetSize: self.imageSizeForPrimaryView, contentMode: .AspectFill, options: options) { [weak self] (image, info) -> Void in
      if self != nil {
        self!.delegate?.imageForPrimaryView(image)
        self!.navigationController?.popToRootViewControllerAnimated(true)
      }
    }
  }
}
