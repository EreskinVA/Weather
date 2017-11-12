//
//  InterfaceController.swift
//  Weather WatchKit Extension
//
//  Created by Sergey Dunaev on 08.11.2017.
//  Copyright © 2017 SSoft. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var windSpeedLabel: WKInterfaceLabel!
    @IBOutlet var conditionsImage: WKInterfaceImage!
    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var feelsLikeLabel: WKInterfaceLabel!
    @IBOutlet var conditionsLabel: WKInterfaceLabel!
    @IBOutlet var shortTermsForecastLabel2: WKInterfaceLabel!
    
    @IBOutlet var longTermForecastTable: WKInterfaceTable!
    @IBOutlet var shortTermsForecastLabel3: WKInterfaceLabel!
    @IBOutlet var shortTermsForecastLabel1: WKInterfaceLabel!
    
    lazy var dataSource: WeatherDataSource = {
        let defaultSystem = UserDefaults.standard.string(forKey: "MeasurementSystem") ?? "Metric"
        if defaultSystem == "Metric" {
            return WeatherDataSource(measurementSystem: .Metric)
        }
        return WeatherDataSource(measurementSystem: .USCustomary)
    }()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "temperatureDidChange"), object: nil, queue: OperationQueue.main) { (notification) in
            if let temperature = notification.userInfo!["temperature"] as? Int {
                self.dataSource.currentWeather._temperature = temperature
                self.updateCurrentforecast()
            }
        }
        
        updateAllForecast()
    }
    
    func updateAllForecast() {
        updateCurrentforecast()
        updateShortTermForecast()
        updateLongTermForecast()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateCurrentforecast() {
        let weather = dataSource.currentWeather
        temperatureLabel.setText(weather.temperatureString)
        feelsLikeLabel.setText(weather.feelTemperatureString)
        windSpeedLabel.setText(weather.windString)
        conditionsLabel.setText(weather.weatherConditionString)
        conditionsImage.setImageNamed(weather.weatherConditionImageName)
    }
    
    func updateShortTermForecast() {
        let labels = [shortTermsForecastLabel1, shortTermsForecastLabel2, shortTermsForecastLabel3]
        let weatherData = [dataSource.shortTermWeather[0], dataSource.shortTermWeather[dataSource.shortTermWeather.count / 2], dataSource.shortTermWeather[dataSource.shortTermWeather.count - 1]]
        for i in 0...2 {
            let label = labels[i]
            let weather = weatherData[i]
            label!.setText("\(weather.intervalString)\n\(weather.temperatureString)")
        }
    }
    
    func updateLongTermForecast() {
        longTermForecastTable.setNumberOfRows(dataSource.longTermWeather.count, withRowType: "LongTermForeCastRow")
        
        for (index, weather) in dataSource.longTermWeather.enumerated() {
            if let row = longTermForecastTable.rowController(at: index) as? LongTermForecastRowController {
                row.conditionsLabel.setText(weather.weatherConditionString)
                row.conditionsImage.setImageNamed(weather.weatherConditionImageName)
                row.temperatureLabel.setText(weather.temperatureString)
                row.dateLabel.setText(weather.intervalString)
            }
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if segueIdentifier == "WeatherDetailSegue" {
            let contex: [String: Any] = ["dataSource": dataSource, "longTermForecastIndex": rowIndex]
            if WCSession.isSupported() {
                let session = WCSession.default
                let weather = dataSource.longTermWeather[rowIndex]
                session.sendMessage(["selectedDay" : weather.intervalString], replyHandler: { (response) in
                    print("Получент ответ от телефона!   =  \(response)")
                }, errorHandler: { (error) in
                    print("Ошибка отправки сообщения! \(error)")
                })
            }
            return contex
        }
        return nil
    }
    
    @IBAction func switchToMetric() {
        
        dataSource = WeatherDataSource(measurementSystem: .Metric)
        updateAllForecast()
        
        UserDefaults.standard.set("Metric", forKey: "MeasurementSystem")
        UserDefaults.standard.synchronize()
        
    }
    
    @IBAction func switchToUSCustomary() {
        
        dataSource = WeatherDataSource(measurementSystem: .USCustomary)
        updateAllForecast()
        
        UserDefaults.standard.set("USCustomary", forKey: "MeasurementSystem")
        UserDefaults.standard.synchronize()
        
    }
    
    @IBAction func shortTernWeather1() {
        showShortTermForecastForIndex(0)
    }
    
    @IBAction func shorttermWeather2() {
        showShortTermForecastForIndex(dataSource.shortTermWeather.count / 2)
    }
    
    @IBAction func shorttermWeather3() {
        showShortTermForecastForIndex(dataSource.shortTermWeather.count - 1)
    }
    
    func showShortTermForecastForIndex(_ index: Int) {
        presentController(withNamesAndContexts: [(name: "WeatherDetailsInterface",
                                                  context: ["dataSource": dataSource, "shortTermForecastIndex": 0, "active": index == 0] as NSDictionary),
                                                 (name: "WeatherDetailsInterface",
                                                  context: ["dataSource": dataSource, "shortTermForecastIndex": dataSource.shortTermWeather.count / 2, "active": index == dataSource.shortTermWeather.count / 2] as NSDictionary),
                                                 (name: "WeatherDetailsInterface",
                                                  context: ["dataSource": dataSource, "shortTermForecastIndex": dataSource.shortTermWeather.count - 1, "active": index == dataSource.shortTermWeather.count - 1] as NSDictionary)
                                                ])
    }
    
}

