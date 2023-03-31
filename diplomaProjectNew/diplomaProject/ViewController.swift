//
//  ViewController.swift
//  diplomaProject
//
//  Created by Имангали on 3/9/23.
//

import UIKit

private enum State {
    case closed
    case open
}
extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class ViewController: UIViewController {
    
    private var floorView: FloorView = {
        let floorView = FloorView()
        return floorView
    }()
    
    private let menuView: MenuView = {
        let menuView = MenuView()
        return menuView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(floorView)
        view.addSubview(menuView)
        view.backgroundColor = UIColor.white
        
        menuView.searchBar.delegate = self
        menuView.tableView.dataSource = self
        menuView.tableView.delegate = self
        
        setupConstraints()
        menuView.setupConstraints()
        floorView.setupConstraints()
        menuView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        menuView.makeRouteButton.addTarget(self, action: #selector(makeRoutePressed), for: .touchUpInside)
        menuView.menuTopView.addGestureRecognizer(panRecognizer)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private var bottomOffset: CGFloat = -280
    private var bottomConstraint = NSLayoutConstraint()
    private var filteredData = [Room]()
    private var isSearching = false
    private var makingRoute = 0
    private var firstRoom = rooms[0]
    private var secondRoom = rooms[1]
    
    private func setupConstraints() {
        bottomOffset += view.frame.height
        menuView.translatesAutoresizingMaskIntoConstraints = false
        floorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuView.heightAnchor.constraint(equalToConstant: view.frame.height - 100),
            
            floorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            floorView.topAnchor.constraint(equalTo: view.topAnchor),
            floorView.heightAnchor.constraint(equalToConstant: view.frame.height),
            floorView.widthAnchor.constraint(equalToConstant: view.frame.width),
        ])
        bottomConstraint = menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomOffset)
        bottomConstraint.isActive = true
        view.layoutIfNeeded()
    }
    
    private var currentState: State = .closed
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()

    private lazy var panRecognizer: InstantPanGestureRecognizer = {
       let recognizer = InstantPanGestureRecognizer()
       recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
       return recognizer
    }()
    @objc func makeRoutePressed() {
        makingRoute = 1
        self.menuView.searchBar.placeholder = "Я нахожусь"
        animateTransitionIfNeeded(to: State.open, duration: 1)
    }
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
            
        // ensure that the animators array is empty (which implies new animations need to be created)
        guard runningAnimators.isEmpty else { return }
        
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.menuView.hideAndShow("open")
            case .closed:
                self.bottomConstraint.constant = self.bottomOffset
                self.menuView.hideAndShow("close")
            }
            self.view.layoutIfNeeded()
        })
        
        // the transition completion block
        transitionAnimator.addCompletion { position in
            
            // update the state
            switch position {
                case .start:
                    self.currentState = state.opposite
                case .end:
                    self.currentState = state
                case .current:
                    ()
            }
            
            // manually reset the constraint positions
            switch self.currentState {
                case .open:
                    self.bottomConstraint.constant = 0
                case .closed:
                    self.bottomConstraint.constant = self.bottomOffset
            }
            
            // remove all running animators
            self.runningAnimators.removeAll()
            
        }
        
        
        // start all animators
        transitionAnimator.startAnimation()
        
        // keep track of all running animators
        runningAnimators.append(transitionAnimator)
        
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            // start the animations
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            
            // pause all animations, since the next event may be a pan changed
            runningAnimators.forEach { $0.pauseAnimation() }
            
            // keep track of each animator's progress
            animationProgress = runningAnimators.map { $0.fractionComplete }
            
        case .changed:
            
            // variable setup
            let translation = recognizer.translation(in: menuView)
            var fraction = -translation.y / (bottomOffset)
            
            // adjust the fraction for the current state and reversed state
            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            
            // apply the new fraction
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
            
        case .ended:
            
            // variable setup
            let yVelocity = recognizer.velocity(in: menuView).y
            let shouldClose = yVelocity > 0
            // if there is no motion, continue all animations and exit early
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            
            // reverse the animations based on their current state and pan motion
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            
            // continue all animations
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
            
        default:
            ()
        }
    }
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
}
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredData.removeAll()
        guard searchText != "" || searchText != " " else {
            print("Empty Search")
            return
        }
        if(searchBar.text == "") {
            isSearching = false
        }
        else {
            isSearching = true
            filteredData = rooms.filter({$0.id.lowercased().contains(searchBar.text?.lowercased() ?? "")})
        }
        menuView.tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(currentState == State.closed) {
            animateTransitionIfNeeded(to: State.open, duration: 1)
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        }
        else {
            return rooms.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor(red: 0.102, green: 0.368, blue: 0.613, alpha: 1)
        cell.textLabel?.textColor = UIColor(red: 0.631, green: 0.725, blue: 0.808, alpha: 1)
        if isSearching {
            cell.textLabel?.text = filteredData[indexPath.row].id
        }
        else {
            cell.textLabel?.text = rooms[indexPath.row].id
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedRoom: Room
        if isSearching {
            selectedRoom = filteredData[indexPath.row]
        }
        else {
            selectedRoom = rooms[indexPath.row]
        }
        if(makingRoute == 1) {
            self.firstRoom = selectedRoom
            self.makingRoute = 2
            menuView.searchBar.searchTextField.text = ""
            menuView.searchBar.placeholder = "До"
            menuView.tableView.reloadData()
            //animateTransitionIfNeeded(to: State.open, duration: 1)
        }
        else if(makingRoute == 2) {
            self.secondRoom = selectedRoom
            self.makingRoute = 0
            floorView.removeCircles()
            floorView.drawPath(firstRoom, secondRoom)
            self.menuView.searchBar.placeholder = "Найти"
            animateTransitionIfNeeded(to: State.closed, duration: 1)
        }
        else {
            animateTransitionIfNeeded(to: State.closed, duration: 1)
            menuView.searchBar.searchTextField.text = selectedRoom.id
            floorView.removeCircles()
            floorView.drawRoom(selectedRoom)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
