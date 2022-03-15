//
//  ViewController.swift
//  Weatherly
//
//  Created by Kishan on 16/08/19.
//  Copyright © 2019 Kishan. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UISearchBarDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var load: UIActivityIndicatorView!
    @IBOutlet weak var weather_TableView: UITableView!
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let url2 = "https://api.openweathermap.org/data/2.5/forecast"

    let APP_ID = "dfad7fb61d55e31811cca5f8520541eb"
    
    let weatherDataModel = WeatherDataModel()
    let locationManager = CLLocationManager()
    
    var lat = CLLocationDegrees()
    var lon = CLLocationDegrees()
    
    var lat1 = CLLocationDegrees()
    var lon1 = CLLocationDegrees()
    var cityName = String()

    var DateArray = [String]()
    var IconArray = [String]()
    var MaxTempArray = [Int]()
    var MinTempArray = [Int]()
    
    
    @IBOutlet weak var showSearchBar: UIButton!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempreture: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    
    
    var searchController:UISearchController!
    var localSearchRequest:MKLocalSearch.Request!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearch.Response!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load.style = .white
        load.startAnimating()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude),latitude = \(location.coordinate.latitude)")
            
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
            
            lat1 = location.coordinate.latitude
            lon1 = location.coordinate.longitude
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            
            
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude,"cnt":"50", "appid" : APP_ID]
            print(params)
            getWeatherData(url: WEATHER_URL, parameters: params)
            print(url2)
            getWeatherData2(url: url2, parameters: params)
            
        }
    }
    
    func getWeatherData(url:String,parameters:[String:String]){
     
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Get the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                self.load.stopAnimating()
                self.load.isHidden = true
                print(weatherJSON)
            }
            else{
                print("Error\(String(describing: response.result.error?.localizedDescription))")
                self.load.stopAnimating()
                self.load.isHidden = true
            }
        }
        weather_TableView.reloadData()

        
    }
    
    func getWeatherData2(url:String,parameters:[String:String]){
        
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Get the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print("shnana he bhai tu",weatherJSON)
                
                if weatherJSON["cnt"].intValue != 0{
                    for i in 0..<weatherJSON["cnt"].intValue{
                        if i % 7 == 0{
                            print(i)
                            let firestimageid = weatherJSON["list"][i]["weather"][0]["id"].intValue
                            let we =  self.weatherDataModel.updateWeatherIcon(condition: firestimageid)
                            self.IconArray.append(we)
                            
                            let name = weatherJSON["list"][i]["dt_txt"].string!
                            self.DateArray.append(self.editStrinf(date: name))
                            
                            let maxtemp = Int(weatherJSON["list"][i]["main"]["temp_max"].double! - 273.15)
                            let mintemp = Int(weatherJSON["list"][i]["main"]["temp_min"].double! - 273.15)
                            self.MaxTempArray.append(maxtemp)
                            self.MinTempArray.append(mintemp)
                            
                        }else{
                            
                        }
                    }
                }else{
                    print("no data found")
                }
                
                print(self.IconArray,self.DateArray,self.MinTempArray,self.MaxTempArray)
                self.weather_TableView.reloadData()
                self.load.stopAnimating()
                self.load.isHidden = true
                
            }
            else{
                print("Error\(String(describing: response.result.error?.localizedDescription))")
                self.load.stopAnimating()
                self.load.isHidden = true
            }
        }
        weather_TableView.reloadData()
    }
    
    
    func editStrinf(date:String)->String{
        
        let endIndex = date.index(date.endIndex, offsetBy: -9)
        let truncated = date.substring(to: endIndex)
        
        return truncated
    }

    func updateWeatherData(json : JSON){
        
        if let tempResult = json["main"]["temp"].double{
            
            weatherDataModel.temperature = Int(tempResult  - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
            
            weatherConditionLabel.text = "so, it's \(json["weather"][0]["description"].stringValue)"

        }
        else{
            cityNameLabel.text = "weather Unavailable!"
        }
        load.stopAnimating()
        load.isHidden = true
        weather_TableView.reloadData()
    }
    
    
    func updateUIWithWeatherData() {
        cityNameLabel.text = "\(weatherDataModel.city)"
        cityName = weatherDataModel.city
        tempreture.text = "\(weatherDataModel.temperature)°C"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityNameLabel.text = "Location unavailable"
    }


    
    @IBAction func Currntlocation(_ sender: Any) {
        DateArray.removeAll()
        IconArray.removeAll()
        MaxTempArray.removeAll()
        MinTempArray.removeAll()
        let params : [String : String] = ["lat" : "\(lat1)", "lon" : "\(lon1)","cnt":"50", "appid" : APP_ID]
        getWeatherData2(url: url2, parameters: params)
        getWeatherData(url: WEATHER_URL, parameters: params)
        lat = lat1
        lon = lon1
        load.isHidden = false
        load.startAnimating()
        weather_TableView.reloadData()
        
    }
    
    @IBAction func SwithchButton(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "weatherCollectionViewController") as! weatherCollectionViewController
            vc.lat = lat
            vc.lon = lon
            vc.cityName = cityName
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    @IBAction func SearchButtonTapped(_ sender: Any) {
        DateArray.removeAll()
        IconArray.removeAll()
        MaxTempArray.removeAll()
        MinTempArray.removeAll()
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self as UISearchBarDelegate
        present(searchController, animated: true, completion: nil)
        
        searchController.searchBar.searchBarStyle = .default
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .black
        
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
            }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //1
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        //2
        localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            
            guard let loclat = localSearchResponse?.boundingRegion.center.latitude else{
            
                let alert = UIAlertController(title: "City name", message: "plese reenter city name", preferredStyle: .alert)
                let action = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert,animated: true,completion: nil)
            
                return
            }
            
            self.lat = loclat
            self.lon = loclat
            
            let loclan = localSearchResponse?.boundingRegion.center.longitude as! Double
            
            let city = String(describing: localSearchResponse!.mapItems[0].name!)
           
            print(city)
            let params : [String : String] = ["lat" : "\(loclat)", "lon" : "\(loclan)","cnt":"50", "appid" : self.APP_ID]
            print(params)
            self.getWeatherData(url: self.WEATHER_URL, parameters: params)
            self.getWeatherData2(url: self.url2, parameters: params)

            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                self.load.isHidden = false
                self.load.startAnimating()
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        load.isHidden = false
        load.startAnimating()
        weather_TableView.reloadData()
    }
    

}

extension ViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        let dates = cell.viewWithTag(1) as! UILabel
        let image = cell.viewWithTag(2) as! UIImageView
        let maxtem = cell.viewWithTag(3) as! UILabel
        let mintem = cell.viewWithTag(4) as! UILabel
        
        dates.text = DateArray[indexPath.row]
        image.image = UIImage(named: IconArray[indexPath.row])
        maxtem.text = "\(MaxTempArray[indexPath.row])"
        mintem.text = "\(MinTempArray[indexPath.row])"
        
        return cell
    }
    
    
    
    
}
