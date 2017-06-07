//
//  ImageExtention.swift
//  AlamofireDemo
//
//  Created by IndiaNIC on 22/06/16.
//  Copyright © 2016 IndiaNIC. All rights reserved.
//

import UIKit

extension UIImage {
    
    var uncompressedPNGData: Data      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:Data   { return UIImageJPEGRepresentation(self, 0.0)!  }
    
    
    // Resize image to new width
    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        
        let aNewWidth = min(newWidth, self.size.width)
        let scale = aNewWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: aNewWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: aNewWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
    
    
    
}

