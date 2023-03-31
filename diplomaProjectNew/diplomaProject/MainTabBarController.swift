//
//  MainTabBarController.swift
//  diplomaProject
//
//  Created by Имангали on 3/15/23.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        generateTabBars()

        // Do any additional setup after loading the view.
    }
    
    private func generateTabBars() {
        viewControllers = [
            generateVC(viewController: ViewController(), title: "Main", image: UIImage(systemName: "house.fill")),
            generateVC(viewController: DrawViewController(), title: "Draw", image: UIImage(systemName: "person.fill"))
        ]
        
    }
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
