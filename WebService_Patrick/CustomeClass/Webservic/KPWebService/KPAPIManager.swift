//
//  PKAPIManager.swift
//  almofireDemo
//
//  Created by Pratik on 18/01/17.
//  Copyright © 2017 Pratik Panchal. All rights reserved.
//

import UIKit
import SystemConfiguration
import Alamofire
import SwiftyJSON


private struct PKAPIStruct {
    
    static let VIDEOTYPES: [String] = ["mov","m4v","mp4"]
    static let AUDIOTYPES: [String] = ["mp3","caf","m4v","aac"]
    static let IMAGETYPES: [String] = ["jpg","jpeg","m4a","aac"]
    
    static let FILE_DATA: String = "file_data"
    static let FILE_KEY: String = "file_key"
    static let FILE_MIME: String = "file_mime"
    static let FILE_EXT: String = "file_ext"
    static let FILE_NAME: String = "file_name"
    static let KEY_PREVIEW_APP = "is_app_preview"
    
}

class PKAPIManager: NSObject {
    
    
    /// Structure for the Default SharedInstance of Sesstion Manager which will be used to call webservice
    struct APIManager {
        
        static let sharedManager: SessionManager = {
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30.0           // Seconds
            configuration.timeoutIntervalForResource = 30.0          // Seconds
            
            return Alamofire.SessionManager(configuration: configuration)
            
        }()
        
    }
    
    
    //MARK: - Network Reachability
    /**
     Network Reachability
     
     - parameter reachableBlock: reachableBlock description
     */
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
        
    }
    
    
    
    
    //MARK: - GET Service
    
    /**
     GET Web Service Method
     
     - parameter url: API URL String
     - parameter param: Parameter description
     - parameter controller: Object of UIViewController
     - parameter completionSuccessBlock: completionSuccessBlock description
     - parameter completionFailureBlock: completionFailureBlock description
     
     ### Usage Example: ###
     ````
     
     
     PKAPIManager.GET(strPostURL, param: nil, controller: self, successBlock: { (jsonResponse) in
     print("success response is received")
     }) { (error, isTimeOut) in
     
     if isTimeOut {
     print("Request Timeout")
     } else {
     print(error?.localizedDescription)
     }
     
     }
     
     ````
     */
    
    class func GET(_ url: String,
                   param: [String: Any]?,
                   controller: UIViewController,
                   successBlock: @escaping (_ response: JSON) -> Void,
                   failureBlock: @escaping (_ error: Error? , _ isTimeOut: Bool) -> Void) {
        
        if PKAPIManager.isConnectedToNetwork() {
            
            // Internet is connected
            
            let headers = [
                "Accept": "application/json"
            ]
            
            print("---- GET REQUEST URL : \(url)")
            print("---- GET REQUEST PARAM : \(param)")
            
            APIManager.sharedManager.request(url, method: .get, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                
                print("---- GET REQUEST URL RESPONSE : \(url)\n\(response.result)")
                
                print(response.timeline)
                
                switch response.result {
                case .success:
                    
                    //                    print(response.request)  // original URL request
                    //                    print(response.response) // HTTP URL response
                    //                    print(response.data)     // server data
                    
                    if let aJSON = response.result.value {
                        
                        let json = JSON(aJSON)
                        print("---- GET SUCCESS RESPONSE : \(json)")
                        successBlock(json)
                        
                    }
                    
                case .failure(let error):
                    
                    print(error)
                    if (error as NSError).code == -1001 {
                        // The request timed out error occured. // Code=-1001 "The request timed out."
                        UIAlertController.showAlertWithOkButton(controller, aStrMessage: "The request timed out. Pelase try after again.", completion: nil)
                        failureBlock(error, true)
                    } else {
                        UIAlertController.showAlertWithOkButton(controller, aStrMessage: error.localizedDescription, completion: nil)
                        failureBlock(error, false)
                    }
                    
                }
                
                
            })
            
        } else {
            
            // Internet is not connected
            UIAlertController.showAlertWithOkButton(controller, aStrMessage: "Internet is not available", completion: nil)
            let aErrorConnection = NSError(domain: "InternetNotAvailable", code: 0456, userInfo: nil)
            failureBlock(aErrorConnection as Error , false)
            
        }
        
    }
    
    
    
    
    //MARK: - POST Service
    
    /**
     POST Web Service Method
     
     - parameter url: API URL String
     - parameter param: Parameter description
     - parameter controller: Object of UIViewController
     - parameter completionSuccessBlock: completionSuccessBlock description
     - parameter completionFailureBlock: completionFailureBlock description
     
     ### Usage Example: ###
     ````
     
     PKAPIManager.POST(strPostURL, param: aDictParam, controller: self, successBlock: { (jsonResponse) in
     print("success response is received")
     }) { (error, isTimeOut) in
     
     if isTimeOut {
     print("Request Timeout")
     } else {
     print(error?.localizedDescription)
     }
     
     }
     
     ````
     */
    
    class func POST(_ url: String,
                    param: [String: Any],
                    controller: UIViewController,
                    successBlock: @escaping (_ response: JSON) -> Void,
                    failureBlock: @escaping (_ error: Error? , _ isTimeOut: Bool) -> Void) {
        
        if PKAPIManager.isConnectedToNetwork() {
            
            // Internet is connected
            
            let headers = [
                "Content-Type": "application/json"
            ]
            
            print("---- POST REQUEST URL : \(url)")
            print("---- POST REQUEST PARAM : \(param)")
            
            APIManager.sharedManager.request(url, method: .post, parameters: param, encoding: JSONEncoding.prettyPrinted, headers: headers).responseJSON(completionHandler: { (response) in
                
                print("---- POST REQUEST URL RESPONSE : \(url)\n\(response.result)")
                
                print(response.timeline)
                
                switch response.result {
                case .success:
                    
                    //                    print(response.request)  // original URL request
                    //                    print(response.response) // HTTP URL response
                    //                    print(response.data)     // server data
                    
                    if let aJSON = response.result.value {
                        
                        let json = JSON(aJSON)
                        print("---- POST SUCCESS RESPONSE : \(json)")
                        successBlock(json)
                        
                    }
                    
                case .failure(let error):
                    
                    print(error)
                    if (error as NSError).code == -1001 {
                        // The request timed out error occured. // Code=-1001 "The request timed out."
                        UIAlertController.showAlertWithOkButton(controller, aStrMessage: "The request timed out. please try after again.", completion: nil)
                        failureBlock(error, true)
                    } else {
                        UIAlertController.showAlertWithOkButton(controller, aStrMessage: error.localizedDescription, completion: nil)
                        failureBlock(error, false)
                    }
                    
                }
                
                
            })
            
        } else {
            
            // Internet is not connected
            UIAlertController.showAlertWithOkButton(controller, aStrMessage: "Internet is not available", completion: nil)
            let aErrorConnection = NSError(domain: "InternetNotAvailable", code: 0456, userInfo: nil)
            failureBlock(aErrorConnection as Error , false)
            
        }
        
    }
    
    
    
    //MARK: - UPLOAD Service
    /**
     UPLOAD Web Service
     
     - parameter url:                    url description
     - parameter param:                  param description
     - parameter completionSuccessBlock: completionSuccessBlock description
     - parameter completionFailureBlock: completionFailureBlock description
     
     ### Usage Example: ###
     ````
     
     let aDictParameter: [String: Any] = [
     "email": "pratik.panchal@gmail.com" as Any,
     "relationship_status": "Single" as Any,
     "doc_url": <Pass URL of file here> as Any,
     "profile_img": UIImage.init(named: "img-sharewith-bg@3x")!,
     "ParamName": "profile_img,doc_url" as Any
     ]
     
     
     PKAPIManager.UPLOAD(strPostURL, param: aDictParameter, controller: self, successBlock: { (jsonResponse) in
     print("success response is received")
     }) { (error, isTimeOut) in
     
     if isTimeOut {
     print("Request Timeout")
     } else {
     print(error?.localizedDescription)
     }
     
     ````
     
     - Remark:
     You have to pass all the "keys" seperated by comma(,) for "ParamName" key which is having Image or File
     
     */
    class func UPLOAD(_ url: String,
                      param: [String: Any],
                      controller: UIViewController,
                      successBlock: @escaping (_ response: JSON) -> Void,
                      failureBlock: @escaping (_ error: Error? , _ isTimeOut: Bool) -> Void) {
        
        
        /*
         
         // Sample Request has to be like this :
         
         let aDictTem: [String: Any] = [
         "email":"pratik.panchal@gmail.com" as Any,
         "relationship_status" : "Single" as Any,
         "doc_url" : <Pass URL of file here> as Any,
         "profile_img":UIImage.init(named: "img-sharewith-bg@3x")!,
         "ParamName":"profile_img,doc_url" as Any]
         
         */
        
        
        if PKAPIManager.isConnectedToNetwork() {
            
            //            MMSwiftSpinner.show("Uploading...")
            
            var aParam = param
            let aStrParamName = aParam["ParamName"] as! String
            let arrKeys = aStrParamName.components(separatedBy: ",")
            var arrMutData = [ [String: Any] ]()
            
            for strKey in arrKeys {
                
                var dictRequestPatamData = [String: Any]()
                print(aParam[strKey]!)
                if aParam[strKey]! is UIImage {
                    
                    let image = aParam[strKey] as! UIImage
                    //                let imageData: NSData = UIImageJPEGRepresentation(image!, 1.0)!
                    let imageData: Data = (image.highQualityJPEGNSData)
                    dictRequestPatamData[PKAPIStruct.FILE_DATA] = imageData
                    dictRequestPatamData[PKAPIStruct.FILE_KEY] = strKey
                    dictRequestPatamData[PKAPIStruct.FILE_NAME] = "\(strKey).png"
                    dictRequestPatamData[PKAPIStruct.FILE_MIME] = "image/jpeg"
                    dictRequestPatamData[PKAPIStruct.FILE_EXT] = "png"
                    
                } else if aParam[strKey]! is NSURL || aParam[strKey]! is URL {
                    
                    let aURL = aParam[strKey] as! URL
                    
                    do {
                        
                        if try aURL.checkResourceIsReachable() {
                            
                            let strFileName: String = aURL.absoluteURL.lastPathComponent
                            let strFileType = strFileName.components(separatedBy: ".").last
                            
                            if let fileData = try? Data(contentsOf: aURL) {
                                // Data is received from URL
                                
                                dictRequestPatamData[PKAPIStruct.FILE_DATA] = fileData
                                dictRequestPatamData[PKAPIStruct.FILE_KEY] = strKey
                                dictRequestPatamData[PKAPIStruct.FILE_NAME] = strFileName
                                
                                if strFileType?.lowercased() == "pdf" {
                                    
                                    dictRequestPatamData[PKAPIStruct.FILE_MIME] = "application/pdf"
                                    dictRequestPatamData[PKAPIStruct.FILE_EXT] = "pdf"
                                    
                                } else if strFileType?.lowercased() == "doc" {
                                    
                                    dictRequestPatamData[PKAPIStruct.FILE_MIME] = "application/msword"
                                    dictRequestPatamData[PKAPIStruct.FILE_EXT] = "doc"
                                    
                                } else if strFileType?.lowercased() == "docx" {
                                    
                                    dictRequestPatamData[PKAPIStruct.FILE_MIME] = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                                    dictRequestPatamData[PKAPIStruct.FILE_EXT] = "docx"
                                    
                                } else if strFileType?.lowercased() == "txt" {
                                    
                                    dictRequestPatamData[PKAPIStruct.FILE_MIME] = "text/plain"
                                    dictRequestPatamData[PKAPIStruct.FILE_EXT] = "txt"
                                    
                                } else if (PKAPIStruct.IMAGETYPES.contains((strFileType?.lowercased())!)) {
                                    
                                    let img : UIImage = UIImage(data: fileData)!
                                    let imageData: Data = (img.highQualityJPEGNSData)
                                    dictRequestPatamData[PKAPIStruct.FILE_DATA] = imageData
                                    dictRequestPatamData[PKAPIStruct.FILE_MIME] = "image/jpeg"
                                    dictRequestPatamData[PKAPIStruct.FILE_EXT] = "png"
                                    
                                } else if (PKAPIStruct.AUDIOTYPES.contains((strFileType?.lowercased())!)) {
                                    
                                    dictRequestPatamData[PKAPIStruct.FILE_MIME] = "Audio/mp3"
                                    dictRequestPatamData[PKAPIStruct.FILE_EXT] = "mp3"
                                    
                                } else if (PKAPIStruct.VIDEOTYPES.contains((strFileType?.lowercased())!)) {
                                    
                                    dictRequestPatamData[PKAPIStruct.FILE_MIME] = "video/mov"
                                    dictRequestPatamData[PKAPIStruct.FILE_EXT] = "mov"
                                    
                                }
                                
                            } else {
                                // Data is not received from URL
                                print("Something went wrong. Unable to Get Data from the URL : \(aURL)")
                                
                            }
                            
                        }
                    }
                    catch {
                        //Handle error
                        print("Exception is occurred. Unable to Get Data from the URL")
                    }
                    
                }
                
                arrMutData.append(dictRequestPatamData)
                aParam.removeValue(forKey: strKey)
                
            }
            
            aParam.removeValue(forKey: "ParamName")
            
            let headers = [
                "Content-Type": "application/json"
            ]
            
            print("---- POST REQUEST URL : \(url)")
            print("---- POST REQUEST PARAM : \(aParam)")
            
            /*
             
             APIManager.sharedManager.upload(multipartFormData: { (multipartFormData) in
             
             for dict in arrMutData {
             
             let aData = dict[PKAPIStruct.FILE_DATA] as! Data
             let strKey = dict[PKAPIStruct.FILE_KEY] as! String
             let strName = dict[PKAPIStruct.FILE_NAME] as! String
             let strMime = dict[PKAPIStruct.FILE_MIME] as! String
             
             multipartFormData.append(aData, withName: strKey, fileName: strName, mimeType: strMime)
             
             }
             
             for (key, value) in aParam {
             if value is String {
             let aStrValue = value as! String
             multipartFormData.append(aStrValue.data(using: .utf8)!, withName: key)
             } else if value is Dictionary<String, Any> {
             let a1dict = value as! [String: Any]
             for (key1, value1) in a1dict {
             if value1 is String {
             let aStrValue1 = value1 as! String
             multipartFormData.append(aStrValue1.data(using: .utf8)!, withName: key1)
             }
             }
             }
             }
             
             }, usingThreshold: 6400, to: url, method: .post, headers: headers, encodingCompletion: { (encodingResult) in
             
             print("---- POST REQUEST URL RESPONSE : \(url)\n\(encodingResult)")
             
             switch encodingResult {
             case .success(let upload, _, _):
             
             upload.responseJSON { response in
             
             print(response.timeline)
             
             if let aJSON = response.result.value {
             
             let json = JSON(aJSON)
             print("---- UPLOAD SUCCESS RESPONSE : \(json)")
             successBlock(json)
             
             }
             
             }
             
             case .failure(let error):
             
             print(error)
             if (error as NSError).code == -1001 {
             // The request timed out error occured. // Code=-1001 "The request timed out."
             UIAlertController.showAlertWithOkButton(controller, aStrMessage: "The request timed out. Pelase try after again.", completion: nil)
             failureBlock(error, true)
             } else {
             UIAlertController.showAlertWithOkButton(controller, aStrMessage: error.localizedDescription, completion: nil)
             failureBlock(error, false)
             }
             
             }
             
             })
             
             */
            
            APIManager.sharedManager.upload(multipartFormData: { (multipartFormData) in
                
                for dict in arrMutData {
                    
                    let aData = dict[PKAPIStruct.FILE_DATA] as! Data
                    let strKey = dict[PKAPIStruct.FILE_KEY] as! String
                    let strName = dict[PKAPIStruct.FILE_NAME] as! String
                    let strMime = dict[PKAPIStruct.FILE_MIME] as! String
                    
                    multipartFormData.append(aData, withName: strKey, fileName: strName, mimeType: strMime)
                    
                }
                
                for (key, value) in aParam {
                    if value is String {
                        let aStrValue = value as! String
                        multipartFormData.append(aStrValue.data(using: .utf8)!, withName: key)
                    } else if value is Dictionary<String, Any> {
                        let a1dict = value as! [String: Any]
                        for (key1, value1) in a1dict {
                            if value1 is String {
                                let aStrValue1 = value1 as! String
                                multipartFormData.append(aStrValue1.data(using: .utf8)!, withName: key1)
                            }
                        }
                    }
                }
                
            }, to: url, encodingCompletion: { (encodingResult) in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        
                        print(response.timeline)
                        
                        if let aJSON = response.result.value {
                            
                            let json = JSON(aJSON)
                            print("---- UPLOAD SUCCESS RESPONSE : \(json)")
                            successBlock(json)
                            
                        }
                        
                    }
                    
                case .failure(let error):
                    
                    print(error)
                    if (error as NSError).code == -1001 {
                        // The request timed out error occured. // Code=-1001 "The request timed out."
                        UIAlertController.showAlertWithOkButton(controller, aStrMessage: "The request timed out. Pelase try after again.", completion: nil)
                        failureBlock(error, true)
                    } else {
                        UIAlertController.showAlertWithOkButton(controller, aStrMessage: error.localizedDescription, completion: nil)
                        failureBlock(error, false)
                    }
                    
                }
                
            })
            
            
        } else {
            
            // Internet is not connected
            UIAlertController.showAlertWithOkButton(controller, aStrMessage: "Internet is not available", completion: nil)
            let aErrorConnection = NSError(domain: "InternetNotAvailable", code: 0456, userInfo: nil)
            failureBlock(aErrorConnection as Error , false)
            
        }
        
    }
    
    
    
    
}
