//
//  TimelineCollectionViewCell.swift
//  ImageFilters
//
//  Created by Josh Nagel on 4/10/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

import UIKit

class TimelineCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  
  func configureCell(timelineImageInfo: TimelineImageInfo) {
    self.tag++
    let tag = self.tag
    self.imageView.image = nil
    if timelineImageInfo.image != nil {
      self.imageView.image = timelineImageInfo.image
    } else {
      ParseService.imageFromPFFile(timelineImageInfo.file, completionHandler: { [weak self] (image, error) -> Void in
        if self != nil {
          if image != nil {
            if tag == self!.tag {
              timelineImageInfo.image = image
              let resizedImage = ImageResizer.resizeImage(image!, size: self!.imageView.frame.size)
              self!.imageView.alpha = 0
              self!.imageView.image = resizedImage
              self!.imageView.transform = CGAffineTransformMakeScale(0.3, 0.3)
              UIView.animateWithDuration(0.5, animations: { () -> Void in
                self!.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self!.imageView.alpha = 1
              })
            }
          }
        }
      })
    }
  }
}
