//
//  weatherCollectionViewController.swift
//  Weatherly
//
//  Created by Kishan on 17/08/19.
//  Copyright © 2019 Kishan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit


class weatherCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var CollectionView: UICollectionView!
    var lat = CLLocationDegrees()
    var lon = CLLocationDegrees()
    var cityName = String()
    
    let weatherDataMode = WeatherDataModel()

    
    let url2 = "https://api.openweathermap.org/data/2.5/forecast"
    
    let APP_ID = "dfad7fb61d55e31811cca5f8520541eb"
    
    var arraytemp = [Int]()
    var arraydate = [String]()
    var arrayid = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let params : [String : String] = ["lat" : "\(lat)", "lon" : "\(lon)","cnt":"50", "appid" : APP_ID]
        cityNameLabel.text = cityName
        getWeatherData(url: url2, parameters: params)
        
        
    }


     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arraytemp.count
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellcol", for: indexPath) as! WeatherCollectionViewCell
        
        let firestimageid = arrayid[indexPath.row]
        let we =  self.weatherDataMode.updateWeatherIcon(condition: firestimageid)
        cell.image.image = UIImage(named: we)
        cell.name.text = "\(arraytemp[indexPath.row])°C"
        cell.time.text = arraydate[indexPath.row]
        
        return cell
    }

    func getWeatherData(url:String,parameters:[String:String]){
        
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Get the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)                
                print("this is legendary",weatherJSON)
                
                for i in 0..<weatherJSON["cnt"].intValue{
                    
                    self.arraytemp.append(Int(weatherJSON["list"][i]["main"]["temp"].double! - 273.15))
                    self.arraydate.append(weatherJSON["list"][i]["dt_txt"].string!)
                    self.arrayid.append(weatherJSON["list"][i]["weather"][0]["id"].intValue)
                    self.CollectionView.reloadData()
                }
            }
            else{
                print("Error\(String(describing: response.result.error?.localizedDescription))")
            }
        }
        
    }
    
    @IBAction func Back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
