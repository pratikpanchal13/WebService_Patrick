//
//  HomeVC.swift
//  WebService_Patrick
//
//  Created by indianic on 07/06/17.
//  Copyright © 2017 indianic. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
class HomeVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{

    
    @IBOutlet var collectionViewHome: UICollectionView!
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
    
    var contentData = [AnyObject]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
     

        
        
        CallAPIToLogin()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contentData.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath as IndexPath) as! CollectionCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.lblTitle.text = self.contentData[indexPath.item]["caption"] as? String
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        
        // Section Left Right -> 6+6 + Min Space cell & Line Middle Space -> 6 + 1

//        let screenSize = UIScreen.main.bounds
//        let screenWidth = screenSize.width
//        let screenHeight = screenSize.height
//        
//        let wh:CGFloat = (screenWidth / 3) - 16
//        let height:CGFloat = ((125*screenWidth)/320)
//        
//        return CGSize((width : self.view.frame.size.width/3) - 16, (height: self.view.frame.size.width/3) - 45);
//        return CGSize(width: wh, height: height)
        
//                return CGSize(width: wh, height: height)
        
        let size = UIScreen.main.bounds.size
        
        // 8 - space between 3 collection cells
        // 4 - 4 times gap will appear between cell.
        return CGSize(width: (size.width - 7 * 8)/6, height: 100)
        

    }
    
    
    //---------------------------------------------------
    //MARK: - API CALL Login
    //---------------------------------------------------
    func CallAPIToLogin()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)

        let loginAPIUrl = "http://212.118.26.115/FileworxMobileServer/api/Account/Login"
        //        let aParameter: [String: Any] = ["userName": self.txtName.text!, "Password":self.txtPassword.text!,"LastLoginLanguageID":"1","AuthenticationType":"0"];
        
        let aParameter: [String: Any] = ["userName": "root", "Password":"root","LastLoginLanguageID":"1","AuthenticationType":"0"];
        
        
        PKAPIManager.POST(loginAPIUrl, param:aParameter, controller: self, successBlock: { (jsonResponse) in
            
            let arrData = jsonResponse["data"]["availableModules"].arrayObject
            //            let dictData = arrData?[0] as! Dictionary<String,Any>
            
            self.contentData = arrData! as [AnyObject]
            
            print("Data is \(self.contentData)")
            
            
            self.collectionViewHome.reloadData()
            
            MBProgressHUD.hide(for: self.view, animated: true)
            print(jsonResponse)
            
            
        })
        {(error, isTimeOut) in
            print("Getting Error")
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class CollectionCell : UICollectionViewCell
{
    
    @IBOutlet var lblTitle: UILabel!
}


