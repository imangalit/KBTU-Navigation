//
//  MenuView.swift
//  diplomaProject
//
//  Created by Имангали on 3/18/23.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class MenuView: UIView, UISearchBarDelegate {
    
    let menuTopView: UIView = {
        let menuTopView = UIView()
        return menuTopView
    }()
    private let menuTopViewLine: UIView = {
        let menuTopViewLine = UIView()
        menuTopViewLine.backgroundColor = UIColor(red: 0.631, green: 0.725, blue: 0.808, alpha: 1)
        menuTopViewLine.layer.cornerRadius = 3
        return menuTopViewLine
    }()
    public let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Найти"
        searchBar.searchTextField.backgroundColor = UIColor(red: 0.082, green: 0.308, blue: 0.517, alpha: 1)
        searchBar.searchTextField.textColor = UIColor(red: 0.631, green: 0.725, blue: 0.808, alpha: 1)
        searchBar.barTintColor = UIColor(red: 0.102, green: 0.368, blue: 0.613, alpha: 1)
        searchBar.searchTextField.leftView?.tintColor = UIColor(red: 0.631, green: 0.725, blue: 0.808, alpha: 1)
        let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchTextField?.attributedPlaceholder = NSAttributedString(string: "Найти", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.631, green: 0.725, blue: 0.808, alpha: 1)])
        return searchBar
    }()
    public let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.backgroundColor = UIColor(red: 0.102, green: 0.368, blue: 0.613, alpha: 1)
        return tableView
    }()
    public func hideAndShow(_ state: String) {
        if state == "open" {
            tableView.isHidden = false
            makeRouteButton.isHidden = true
        }
        else {
            tableView.isHidden = true
            makeRouteButton.isHidden = false
        }
    }
    public let makeRouteButton: UIButton = {
        let makeRouteButton = UIButton()
        makeRouteButton.isHidden = false
        makeRouteButton.layer.cornerRadius = 10
        makeRouteButton.setTitle("Построить маршрут", for: .normal)
        makeRouteButton.backgroundColor = UIColor(red: 0.082, green: 0.308, blue: 0.517, alpha: 1)
        makeRouteButton.setTitleColor(UIColor(red: 0.631, green: 0.725, blue: 0.808, alpha: 1), for: .normal)
        makeRouteButton.titleLabel?.text = "Построить маршрут"
        return makeRouteButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.102, green: 0.368, blue: 0.613, alpha: 1)
        layer.cornerRadius = 10
        
        addSubview(menuTopView)
        addSubview(searchBar)
        addSubview(tableView)
        addSubview(makeRouteButton)
        
        menuTopView.addSubview(menuTopViewLine)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        menuTopView.translatesAutoresizingMaskIntoConstraints = false
        menuTopViewLine.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        makeRouteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            menuTopView.centerXAnchor.constraint(equalTo: centerXAnchor),
            menuTopView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            menuTopView.widthAnchor.constraint(equalToConstant: frame.size.width),
            menuTopView.heightAnchor.constraint(equalToConstant: 40),
            
            menuTopViewLine.centerXAnchor.constraint(equalTo: menuTopView.centerXAnchor),
            menuTopViewLine.centerYAnchor.constraint(equalTo: menuTopView.centerYAnchor),
            menuTopViewLine.widthAnchor.constraint(equalToConstant: frame.width * 0.5),
            menuTopViewLine.heightAnchor.constraint(equalToConstant: 3),
            
            searchBar.centerXAnchor.constraint(equalTo: centerXAnchor),
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            searchBar.widthAnchor.constraint(equalToConstant: frame.size.width - 20),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 50),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            makeRouteButton.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 60),
            makeRouteButton.widthAnchor.constraint(equalToConstant: frame.size.width - 30),
            makeRouteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            makeRouteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

