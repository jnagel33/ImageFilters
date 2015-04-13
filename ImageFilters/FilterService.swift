//
//  FilterService.swift
//  ImageFilters
//
//  Created by Josh Nagel on 4/6/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

import UIKit
import CoreImage

class FilterService {
  
  class func pinchDistortionFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIPinchDistortion")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func dotScreenFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIDotScreen")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func lineScreenFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CILineScreen")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func pixellateFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIPixellate")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func vibranceFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIVibrance")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func colorMatrixFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIColorMatrix")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func photoEffectTransferFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIPhotoEffectTransfer")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func greenMonochromeFilter(image: UIImage, context: CIContext) -> UIImage {
    let greenColor = CIColor(red: 0.05, green: 0.40, blue: 0.05)
    let filter = CIFilter(name: "CIColorMonochrome",
      withInputParameters: ["inputColor" : greenColor, "inputIntensity" : 1.0])
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func hueAdjustFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIHueAdjust")
    filter.setValue(2.084, forKey: kCIInputAngleKey)
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func blueMonochromeFilter(image: UIImage, context: CIContext) -> UIImage {
    let blueColor = CIColor(red: 0.05, green: 0.05, blue: 0.40)
    let filter = CIFilter(name: "CIColorMonochrome",
      withInputParameters: ["inputColor" : blueColor, "inputIntensity" : 1.0])
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func gaussianBlurFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIGaussianBlur")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func vignetteFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIVignette")
    filter.setDefaults()
    filter.setValue(2, forKey: kCIInputIntensityKey)
    filter.setValue(30, forKey: kCIInputRadiusKey)
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func photoEffectInstantFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIPhotoEffectInstant")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func photoEffectFadeFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIPhotoEffectFade")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func photoEffectChromeFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIPhotoEffectChrome")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func sepiaToneFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CISepiaTone")
    filter.setValue(0.5, forKey: kCIInputIntensityKey)
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func photoEffectNoirFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIPhotoEffectNoir")
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func colorPosterizeFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIColorPosterize")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  class func colorInvertFilter(image: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIColorInvert")
    filter.setDefaults()
    return self.createImageFromFilter(filter, image: image, context: context)
  }
  
  private class func createImageFromFilter(filter: CIFilter?, image: UIImage, context: CIContext) -> UIImage {
    let image = CIImage(image: image)
    filter!.setValue(image, forKey: kCIInputImageKey)
    let result = filter!.valueForKey(kCIOutputImageKey) as! CIImage
    let resultRef = context.createCGImage(result, fromRect: result.extent())
    return UIImage(CGImage: resultRef)!
  }
}
