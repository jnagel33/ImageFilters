//
//  ParseService.swift
//  ImageFilters
//
//  Created by Josh Nagel on 4/7/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

import Foundation

class ParseService {
  
  class func uploadImageInfo(image: UIImage, title: String?, message: String?, size: CGSize, completionHandler: (Bool?, NSError?) -> Void) {
    let resizedImage = ImageResizer.resizeImage(image, size: size)
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    let imageFile = PFFile(name: "post.jpg", data: imageData)
    let post = PFObject(className: "Post")
    let deviceUDID = UIDevice.currentDevice().identifierForVendor.UUIDString;
    post["user"] = deviceUDID
    post["imageFile"] = imageFile
    if title != nil {
      post["title"] = title
    }
    if message != nil {
      post["message"] = message
    }
    post.saveInBackgroundWithBlock { (success, error) -> Void in
      if error != nil {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          completionHandler(nil, error)
        })
      } else {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          completionHandler(success, nil)
        })
      }
    }
  }
  
  class func fetchPosts(date: NSDate?, completionHandler: ([PFObject]?, NSError?) -> Void) {
    var query = PFQuery(className: "Post")
    if let lastItemDate = date {
      query.whereKey("createdAt", greaterThan: lastItemDate)
    }
    let deviceUDID = UIDevice.currentDevice().identifierForVendor.UUIDString;
    query.whereKey("user", equalTo: deviceUDID)
    query.orderByDescending("createdAt")
    query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
      if error != nil {
        completionHandler(nil, error)
      } else {
        let posts = objects as! [PFObject]
        completionHandler(posts, nil)
      }
    }
  }
  
  class func imageFromPFFile(file: PFFile, completionHandler: (UIImage?, NSError?) -> Void) {
    file.getDataInBackgroundWithBlock { (data, error) -> Void in
      if error != nil {
        completionHandler(nil, error)
      } else {
        if let image = UIImage(data: data!) {
          completionHandler(image, nil)
        }
      }
    }
  }
  
  class func deleteImageRecord(objectId: String, completionHandler: (Bool, NSError?) -> Void) {
    var query = PFQuery(className: "Post")
    var error: NSError?
    
    query.whereKey("objectId", equalTo: objectId)
    query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
      if error != nil {
       completionHandler(false, error)
      } else {
        let foundObjects = objects as! [PFObject]
        foundObjects[0].deleteInBackgroundWithBlock({ (success, error) -> Void in
          if error != nil {
            completionHandler(false, error)
          } else {
            completionHandler(success, nil)
          }
        })
      }
    }
  }
  class func updateImageRecord(timelineImageInfo: TimelineImageInfo, completionHandler: (Bool, NSError?) -> Void) {
    
    var query = PFQuery(className:"Post")
    query.getObjectInBackgroundWithId(timelineImageInfo.objectId) {
      (imageRecord: PFObject?, error: NSError?) -> Void in
      if error != nil {
      } else if let imageRecord = imageRecord {
        if let title = timelineImageInfo.title {
          imageRecord["title"] = title
        }
        if let message = timelineImageInfo.message {
          imageRecord["message"] = message
        }
        imageRecord.saveInBackgroundWithBlock({ (success, error) -> Void in
          completionHandler(success, error)
        })
      }
    }
  }
}
