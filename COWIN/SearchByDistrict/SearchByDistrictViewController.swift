//
//  SearchByDistrictViewController.swift
//  COWIN
//
//  Created by Nemi Shah on 01/05/21.
//

import Foundation
import UIKit

class SearchByDistrictViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let statePickerTag: Int = 1
    let districtPickerTag: Int = 2
    var isLoading: Bool = true {
        didSet {
            if isLoading {
                self.view.showLoader()
            } else {
                self.view.hideLoader()
            }
        }
    }
    
    let viewModel = SearchByDistrictViewModel()
    var statesList: [State] = []
    var statePicker: UIPickerView?
    var districtPicker: UIPickerView?
    var stateToolBar: UIToolbar?
    var districtToolBar: UIToolbar?
    let stateLabel: UILabel = UILabel()
    let districtLabel: UILabel = UILabel()
    let stateNameContainer: UIView = UIView()
    let districtNameContainer: UIView = UIView()
    let tableView: UITableView = UITableView()
    let datesContainer: UIView = UIView()
    var currentStateId: Int = 0
    var currentDistrictId: Int = 0
    var districtsList: [District] = []
    var datesToDisplay: [String] = []
    var currentlySelectedDate: String = ""
    var centersData: [Center] = []
    
    let userDefaultsStateKey = "selectedStateId"
    let userDefaultsDistrictId = "selectedDistrictId"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Search by district"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.isNavigationBarHidden = false
        
        self.addLabels()
        self.addDatePicker()
        self.addTableView()
        
        self.isLoading = true
    }
    
    func addLabels() {
        // State
        self.view.addSubview(stateNameContainer)
        
        stateNameContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        stateNameContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        stateNameContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        stateNameContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stateNameContainer.translatesAutoresizingMaskIntoConstraints = false
        
        stateNameContainer.layer.borderWidth = 1
        stateNameContainer.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        stateNameContainer.layer.cornerRadius = 4
        stateNameContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStateClicked)))
        
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.text = "Select state"
        stateLabel.textColor = UIColor.black
        
        stateNameContainer.addSubview(stateLabel)
        
        stateLabel.leadingAnchor.constraint(equalTo: stateNameContainer.leadingAnchor, constant: 8).isActive = true
        stateLabel.trailingAnchor.constraint(equalTo: stateNameContainer.trailingAnchor, constant: 8).isActive = true
        stateLabel.centerYAnchor.constraint(equalTo: stateNameContainer.centerYAnchor).isActive = true
        
        // District
        self.view.addSubview(districtNameContainer)
        
        districtNameContainer.topAnchor.constraint(equalTo: stateNameContainer.bottomAnchor, constant: 16).isActive = true
        districtNameContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        districtNameContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        districtNameContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        districtNameContainer.translatesAutoresizingMaskIntoConstraints = false
        
        districtNameContainer.layer.borderWidth = 1
        districtNameContainer.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        districtNameContainer.layer.cornerRadius = 4
        districtNameContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDistrictClicked)))
        
        districtLabel.translatesAutoresizingMaskIntoConstraints = false
        districtLabel.text = "Select district"
        districtLabel.textColor = UIColor.black
        
        districtNameContainer.addSubview(districtLabel)
        
        districtLabel.leadingAnchor.constraint(equalTo: districtNameContainer.leadingAnchor, constant: 8).isActive = true
        districtLabel.trailingAnchor.constraint(equalTo: districtNameContainer.trailingAnchor, constant: 8).isActive = true
        districtLabel.centerYAnchor.constraint(equalTo: districtNameContainer.centerYAnchor).isActive = true
    }
    
    func addTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sessionCell")
        
        self.view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: datesContainer.bottomAnchor, constant: 16).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    func addDatePicker() {
        datesContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(datesContainer)
        
        datesContainer.topAnchor.constraint(equalTo: districtNameContainer.bottomAnchor, constant: 8).isActive = true
        datesContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        datesContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        datesContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        prepareDates()
        currentlySelectedDate = datesToDisplay[0]
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 50), collectionViewLayout: flowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "dateCell")
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.dataSource = self
        collectionView.delegate = self
        
        datesContainer.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: datesContainer.topAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: datesContainer.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: datesContainer.trailingAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: datesContainer.bottomAnchor, constant: 0).isActive = true
    }
    
    func prepareDates() {
        var dates: [String] = []
        
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        
        let currentDate: Date = Date()
        dates.append(df.string(from: currentDate))
        
        for i in 1...30 {
            if let newDate: Date = Calendar.current.date(byAdding: .day, value: i, to: currentDate) {
                dates.append(df.string(from: newDate))
            }
        }
        
        datesToDisplay = dates
    }
    
    override func viewDidLoad() {
        viewModel.getStatesList() { (states, error) in
            self.statesList = states?.states ?? []
            if let selectedStateId: Int = UserDefaults.standard.value(forKey: self.userDefaultsStateKey) as? Int, let selectedState: State = self.getStateFromList(forId: selectedStateId) {
                DispatchQueue.main.async {
                    self.stateLabel.text = selectedState.stateName
                    self.currentStateId = selectedStateId
                    self.fetchDistricts()
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    func getStateFromList(forId: Int) -> State? {
        var stateToReturn: State?
        
        for state in statesList {
            if state.stateId == forId {
                stateToReturn = state
                break
            }
        }
        
        return stateToReturn
    }
    
    @objc func onStateClicked() {
        statePicker = UIPickerView()
        statePicker?.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        statePicker?.tag = statePickerTag
        statePicker?.delegate = self
        statePicker?.dataSource = self
        statePicker?.contentMode = .center
        statePicker?.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(self.statePicker!)
        
        stateToolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        stateToolBar?.barStyle = UIBarStyle.black
        stateToolBar?.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onStateToolbarDoneTapped))]
        self.view.addSubview(stateToolBar!)
    }
    
    @objc func onDistrictClicked() {
        districtPicker = UIPickerView()
        districtPicker?.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        districtPicker?.tag = districtPickerTag
        districtPicker?.delegate = self
        districtPicker?.dataSource = self
        districtPicker?.contentMode = .center
        districtPicker?.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(self.districtPicker!)
        
        districtToolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        districtToolBar?.barStyle = UIBarStyle.black
        districtToolBar?.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDistrictToolbarDoneTapped))]
        self.view.addSubview(districtToolBar!)
    }
    
    @objc func onStateToolbarDoneTapped() {
        stateToolBar?.removeFromSuperview()
        statePicker?.removeFromSuperview()
        self.view.showLoader()
        self.fetchDistricts()
    }
    
    func fetchDistricts() {
        viewModel.getDistrictForState(stateId: currentStateId) { (data, error) in
            self.districtsList = data?.districts ?? []
            
            if let selectedDistrictId: Int = UserDefaults.standard.value(forKey: self.userDefaultsDistrictId) as? Int, let selectedDistrict: District = self.getDistrictFromList(forId: selectedDistrictId) {
                DispatchQueue.main.async {
                    self.districtLabel.text = selectedDistrict.districtName
                    self.currentDistrictId = selectedDistrictId
                    self.getSlotsInfo()
                }
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func getDistrictFromList(forId: Int) -> District? {
        var districtToReturn: District?
        
        for district in districtsList {
            if district.districtId == forId {
                districtToReturn = district
                break
            }
        }
        
        return districtToReturn
    }
    
    func getSlotsInfo() {
        viewModel.fetchSlotsInfo(forDate: currentlySelectedDate, forDistrictId: currentDistrictId) { (centersData, error) in
            self.centersData = centersData?.centers ?? []
            DispatchQueue.main.async {
                self.isLoading = false
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func onDistrictToolbarDoneTapped() {
        districtToolBar?.removeFromSuperview()
        districtPicker?.removeFromSuperview()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == statePickerTag {
            return statesList.count
        }
        
        return districtsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == statePickerTag {
            return statesList[row].stateName
        }
        
        return districtsList[row].districtName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == statePickerTag {
            onStateSelected(stateId: statesList[row].stateId ?? 0, stateName: statesList[row].stateName)
        } else {
            onDistrictSelected(districtId: districtsList[row].districtId ?? 0, districtName: districtsList[row].districtName)
        }
    }
    
    func onStateSelected(stateId: Int, stateName: String?) {
        stateLabel.text = stateName
        currentStateId = stateId
        UserDefaults.standard.setValue(currentStateId, forKey: userDefaultsStateKey)
        clearDistrictSelection()
    }
    
    func onDistrictSelected(districtId: Int, districtName: String?) {
        districtLabel.text = districtName
        currentDistrictId = districtId
        UserDefaults.standard.setValue(currentDistrictId, forKey: userDefaultsDistrictId)
    }
    
    func clearDistrictSelection() {
        districtLabel.text = "Select district"
        currentDistrictId = 0
        UserDefaults.standard.setValue(currentDistrictId, forKey: userDefaultsDistrictId)
    }
}

extension SearchByDistrictViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datesToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let view: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath)
        
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        
        let dateToDisplay: String = datesToDisplay[indexPath.row]
        let isSelected = currentlySelectedDate == dateToDisplay
        let selectedColor: UIColor = UIColor.systemGreen.withAlphaComponent(0.7)
        
        view.backgroundColor = isSelected ? selectedColor : UIColor.white
        view.layer.borderWidth = 1
        view.layer.borderColor = isSelected ? selectedColor.cgColor : UIColor.gray.withAlphaComponent(0.4).cgColor
        view.layer.cornerRadius = 4
        
        let dateLabel: UILabel = UILabel()
        dateLabel.textColor = isSelected ? UIColor.white : UIColor.black
        dateLabel.text = dateToDisplay
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(dateLabel)
        
        dateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dateSelected: String = datesToDisplay[indexPath.row]
        currentlySelectedDate = dateSelected
        collectionView.reloadData()
        self.isLoading = true
        self.getSlotsInfo()
    }
}

extension SearchByDistrictViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return centersData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let center: Center = centersData[section]
        return center.sessions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "sessionCell")!
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.gray.withAlphaComponent(0.5) : UIColor.gray
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        if let session: Session = centersData[indexPath.section].sessions?[indexPath.row] {
            let minimumAgeLabel: UILabel = UILabel()
            minimumAgeLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let minimumAge = session.minAgeLimit ?? -1
            minimumAgeLabel.text = "Age Limit: \(minimumAge)+"
            minimumAgeLabel.textColor = UIColor.black
            minimumAgeLabel.font = UIFont.systemFont(ofSize: 12)
            
            cell.addSubview(minimumAgeLabel)
            minimumAgeLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 8).isActive = true
            minimumAgeLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8).isActive = true
            minimumAgeLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -48).isActive = true
            
            let availableSlotsCountContainer: UIView = UIView()
            availableSlotsCountContainer.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(availableSlotsCountContainer)
            availableSlotsCountContainer.layer.borderWidth = 1
            availableSlotsCountContainer.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
            
            availableSlotsCountContainer.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            availableSlotsCountContainer.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            availableSlotsCountContainer.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            availableSlotsCountContainer.widthAnchor.constraint(equalToConstant: 48).isActive = true
            
            var countBackground: UIColor = UIColor.systemGreen
            let availableCount: Int = session.availableCapacity ?? 0
            
            if (availableCount == 0) {
                countBackground = UIColor.systemRed
            } else if (availableCount < 30) {
                countBackground = UIColor.systemYellow
            }
            
            availableSlotsCountContainer.backgroundColor = countBackground
            
            let availableSlotsLabel: UILabel = UILabel()
            availableSlotsLabel.translatesAutoresizingMaskIntoConstraints = false
            availableSlotsLabel.textColor = UIColor.white
            availableSlotsLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            availableSlotsLabel.text = "\(availableCount)"
            
            availableSlotsCountContainer.addSubview(availableSlotsLabel)
            
            availableSlotsLabel.centerYAnchor.constraint(equalTo: availableSlotsCountContainer.centerYAnchor).isActive = true
            availableSlotsLabel.centerXAnchor.constraint(equalTo: availableSlotsCountContainer.centerXAnchor).isActive = true
            
            let vaccine: String = session.vaccine ?? ""
            
            if !vaccine.isEmpty {
                let vaccineLabel: UILabel = UILabel()
                vaccineLabel.translatesAutoresizingMaskIntoConstraints = false
                vaccineLabel.textColor = UIColor.black
                vaccineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                vaccineLabel.text = "Vaccine type: \(vaccine)"
                
                cell.addSubview(vaccineLabel)
                
                vaccineLabel.topAnchor.constraint(equalTo: minimumAgeLabel.bottomAnchor, constant: 8).isActive = true
                vaccineLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8).isActive = true
                vaccineLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -48).isActive = true
                vaccineLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -8).isActive = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 100))
        headerView.backgroundColor = .white
        
        let dividerView: UIView = UIView(frame: CGRect(x: 0, y: 4, width: tableView.frame.width, height: 1))
        dividerView.backgroundColor = UIColor.black
        
        headerView.addSubview(dividerView)
        
        let nameLabel: UILabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = UIColor.black
        nameLabel.text = "\(centersData[section].name ?? "") (\(centersData[section].pincode ?? -1))"
        nameLabel.numberOfLines = 2
        
        headerView.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 4).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -4).isActive = true
        
        let feeTypeContainer: UIView = UIView(frame: CGRect(x: 4, y: 54, width: 60, height: 20))
        feeTypeContainer.layer.cornerRadius = 10
        feeTypeContainer.backgroundColor = centersData[section].feeType?.lowercased() == "free" ? UIColor.systemGreen : UIColor.systemOrange
        let feeTypeLabel: UILabel = UILabel()
        feeTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        feeTypeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        feeTypeLabel.layer.cornerRadius = 4
        feeTypeLabel.textColor = UIColor.white
        feeTypeLabel.text = centersData[section].feeType
        
        feeTypeContainer.addSubview(feeTypeLabel)
        
        feeTypeLabel.centerXAnchor.constraint(equalTo: feeTypeContainer.centerXAnchor).isActive = true
        feeTypeLabel.centerYAnchor.constraint(equalTo: feeTypeContainer.centerYAnchor).isActive = true
        
        headerView.addSubview(feeTypeContainer)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
}
