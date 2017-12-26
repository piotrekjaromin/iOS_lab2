import UIKit
import Alamofire
import DGElasticPullToRefresh

class MessageTableViewController: UITableViewController {
    
    var messages: [Message] = []
    
    @IBAction func composeMessage(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: NSLocalizedString("modalTitle", comment: ""), message: NSLocalizedString("modalDescription", comment: ""), preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("name", comment: "")
        } )
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("message", comment: "")
        } )
        let sendAction = UIAlertAction(title: NSLocalizedString("send", comment: ""), style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            self.sendMessage(name: name!, message: message!)
            self.getMessages()
            
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: { _ in })
    }

    
    func getMessages() {
        let url = URL(string: "https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2017")
        Alamofire.request(
            url!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON {
            
            (response) -> Void in
                guard response.result.isSuccess else {
                    print("Error: \(response.result.error)")
                    //completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                    let messagesJson = value["entries"] as? [[String: Any]] else {
                        print("Malfolmed data received.")
                        return;
                }
                
                self.messages = []
                for messageJson in messagesJson{
                    let name = messageJson["name"]! as! String
                    let message = messageJson["message"]! as! String
                    let timestamp = self.getMinFromDate(dateString: messageJson["timestamp"]! as! String)
                    self.messages.append(Message(timestamp: timestamp, name: name, message: message))
                }
                self.messages = self.messages.sorted(by: {$0.timestamp < $1.timestamp})
                self.tableView.reloadData()
        }
    }
    
    

    func sendMessage(name: String, message: String) {
        let URL1 = "https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2017"
        //let url = URL(URL1)
        let parameters = ["name": name, "message": message]
        
        Alamofire.request(URL1, method: .post, parameters: parameters).responseJSON {
            response in print(response)
        }
        
    }

    @IBAction func refreshMessages(_ sender: UIRefreshControl) {
        getMessages()
        
        refreshControl?.endRefreshing()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getMessages()
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "MessageTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageTableViewCell
        
        let message = messages[indexPath.row]
        
        cell.timestamp.text = "\(message.timestamp)" + NSLocalizedString("minutesago", comment: "")
        cell.details.text = "\(message.name) " + NSLocalizedString("says", comment: "") + " \(message.message)"

        return cell
    }
    
    func getMinFromDate(dateString: String) -> Int {
        let dateFormatter = DateFormatter()
        print(dateString)
        dateFormatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        let date = (-dateFormatter.date(from: dateString)!.timeIntervalSinceNow) / 60
        print(date)
        return Int(date)
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
