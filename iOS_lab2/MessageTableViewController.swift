import UIKit

class MessageTableViewController: UITableViewController {
    
    var messages: [Message] = []
    
    @IBAction func composeMessage(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New message", message: "Please state your name and message", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your name"
        } )
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your message"
        } )
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            self.sendMessage(name: name!, message: message!)
            self.getMessages()
            
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: { _ in })
    }
    
    func getMessages() {
        let url = URL(string: "https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2017")
        
        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) -> Void in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                if let messagesJson = jsonObj!.value(forKey: "entries") as? NSArray {
                    self.messages = []
                    for messageJson in messagesJson{
                        let name = (messageJson as AnyObject).value(forKey: "name")! as! String
                        let message = (messageJson as AnyObject).value(forKey: "message")! as! String
                        let timestamp = (messageJson as AnyObject).value(forKey: "timestamp")! as! String
                        self.messages.append(Message(timestamp: timestamp, name: name, message: message))
                    }
                }
                OperationQueue.main.addOperation({
                    self.messages = self.messages.sorted(by: {$0.timestamp > $1.timestamp})
                    self.tableView.reloadData()
                })
            }
        }).resume()
        
    }
    
    
    @IBAction func refreshMessages(_ sender: UIRefreshControl) {
        getMessages()
        
        refreshControl?.endRefreshing()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getMessages()

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
        
        cell.timestamp.text = String(message.timestamp)
        cell.details.text = "\(message.name) says: \(message.message)"

        return cell
    }
    
    func sendMessage(name: String, message: String) {
        let url = URL(string: "https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2017")
        
        let parameters = ["message": message, "name": name]
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                }
            } catch let error {
                print(error)
            }
            
        })
        
        task.resume()
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
