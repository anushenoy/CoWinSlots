//
//  ViewController.swift
//  COWIN
//
//  Created by Anush on 01/05/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var PincodeLbl: UILabel!
    
    @IBOutlet weak var emptyStateLbl: UILabel!
    let viewModel = ViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableFooterView = UIView()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing data")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        if let pin = UserDefaults.standard.string(forKey: "pincode"){
            self.doStuffForPincode(pin: pin)
        }else{
            showPinPopup()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = .black
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = viewModel.centers[section].name
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        
        headerView.addSubview(label)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.centers.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.centers[section].sessions?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SessionTableViewCell
        guard viewModel.centers.count > indexPath.section else{
            return cell
        }
        guard viewModel.centers[indexPath.section].sessions?.count ?? 0 > indexPath.row else{
            return cell
        }
        let item = viewModel.centers[indexPath.section].sessions?[indexPath.row]
        var str = item?.date
        if let vaxType = item?.vaccine, !vaxType.isEmpty{
            str?.append("\nVaccine: \(vaxType)")
        }
        if let ageType = item?.minAgeLimit{
            str?.append("\nAge group: \(ageType)+")
        }
        
        cell.detailsLbl?.text = str
        let availableslots = item?.availableCapacity ?? 0
        cell.countLbl?.text = "\(availableslots) slots"
        cell.statusIndicator.backgroundColor = (availableslots == 0) ? .red : .green
        cell.selectionStyle = .none
        return cell
    }
    @IBAction func changePincodeClicked(_ sender: Any) {
        
        showPinPopup()
        
    }
    
    @IBAction func searchByDistrictClicked(_ sender: Any) {
        self.navigationController?.pushViewController(SearchByDistrictViewController(), animated: true)
    }
    
    func showPinPopup(){
        var alertController:UIAlertController?
                alertController = UIAlertController(title: "Cowin Status",
                                                    message: "Enter a valid pincode",
                                                    preferredStyle: .alert)

        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                        textField.placeholder = "Enter pincode here"
                textField.keyboardType = .numberPad
                
                })

                let action = UIAlertAction(title: "Submit",
                                           style: UIAlertAction.Style.default,
                                           handler: {[weak self]
                                           (paramAction:UIAlertAction!) in
                                           
                                            let predicate = NSPredicate(format:"SELF MATCHES %@", "[1-9]{1}[0-9]{5}")
                                            if let enteredTextField = alertController?.textFields?.first, let enteredText = enteredTextField.text, predicate.evaluate(with: enteredText) {
                                                UserDefaults.standard.setValue(enteredText, forKey: "pincode")
                                                self?.doStuffForPincode(pin: enteredText)
                                            }else{
                                                self?.showPinPopup()
                                            }
                })
        let action1 = UIAlertAction(title: "Cancel",
                                   style: UIAlertAction.Style.cancel,
                                   handler: nil)
                alertController?.addAction(action)
                alertController?.addAction(action1)
        self.present(alertController!,animated: true, completion: nil)
    }
    func doStuffForPincode(pin:String){
        self.PincodeLbl.text = pin
        self.view.showLoader()
        viewModel.getdata(pincode: pin){
            //dostuff
            print(self.viewModel.centers)
            DispatchQueue.main.async {
                self.view.hideLoader()
                
                self.emptyStateLbl.isHidden   = !self.viewModel.centers.isEmpty
           
                    self.tableView.reloadData()
               
            }
        }
    }
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        viewModel.getdata(pincode: self.PincodeLbl.text ?? ""){
            //dostuff
            print(self.viewModel.centers)
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                
                self.emptyStateLbl.isHidden   = !self.viewModel.centers.isEmpty
           
                    self.tableView.reloadData()
               
            }
        }
    }
}

