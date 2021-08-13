//
//  ViewController.swift
//  FinamTest
//
//  Created by Admin on 13.08.2021.
//

import UIKit
import Alamofire

struct CommonInfo : Decodable {
    var status : String?
    var totalResults : Int?
    var articles : [Articles]?
}
struct Articles : Decodable {
    var source : Source?
    var author : String?
    var title : String
    var description : String
    var url : URL
    var urlToImage : URL
    var publishedAt : String
    var content : String?
}
struct Source : Decodable {
    var id : String?
    var name : String
}


class ViewController: UIViewController {

    @IBOutlet weak var commonTable: UITableView!
    
    var newsArray : [Articles]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Срочные новости:"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        AF.request("https://newsapi.org/v2/top-headlines?country=ru&category=technology&apiKey=8f825354e7354c71829cfb4cb15c4893").responseJSON { response in
            print(response)
            do {
                let commonInfo = try JSONDecoder().decode(CommonInfo.self, from: response.data!)
                self.newsArray = commonInfo.articles
                print(commonInfo)
                self.commonTable.reloadData()
            } catch let error {
                print(error)
            }
        } .resume()
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyTableViewCell
        let model = newsArray![indexPath.row]
        cell.newsLabel.numberOfLines = 1
        cell.titleLabel.numberOfLines = 0
        cell.newsLabel.sizeToFit()
        cell.titleLabel.sizeToFit()
        cell.titleLabel.text = model.title
        cell.newsLabel.text = model.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = newsArray![indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        secondViewController.textInfo = topic.description
        self.present(secondViewController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
