//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation
protocol CoinManagerDelegate {
    func didUpdateCurrency(_ coinManager: CoinManager, coin: CoinModel) -> Void
    func didFailWithError(error: Error) -> Void
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "76946A0D-2E0F-44A3-BD85-3A98BB7F81C0"
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["KZT","AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func fetchCoinRate(from currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func getCoinPrice(for currency: String){
        fetchCoinRate(from: currency)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let coin = self.parseJSON(safeData) {
                        self.delegate?.didUpdateCurrency(self, coin: coin)
//                        print(coin)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let time = decodedData.time
            let coin = decodedData.asset_id_base
            let fiat = decodedData.asset_id_quote
            let rate = decodedData.rate
            
            let resp = CoinModel(time: time, coin: coin, fiat: fiat, rate: rate)
            return resp
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
