import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpControllers()
    }

    private func setUpControllers() {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            AuthManager.shared.signOut { _ in
                // do nothing
            }
            return
        }
        guard let currentUserName = UserDefaults.standard.string(forKey: "name") else {
            AuthManager.shared.signOut { _ in
                // do nothing
            }
            return
        }
        guard let currentUserPhone = UserDefaults.standard.string(forKey: "phone") else {
            AuthManager.shared.signOut { _ in
                // do nothing
            }
            return
        }
        
        let home = HomeViewController2()
        home.title = "Developing centers"
        let profile = ProfileViewController(currentEmail: currentUserEmail, currentName: currentUserName, currentPhone: currentUserPhone)
        profile.title = "Profile"
        let calendarVC = CalendarViewController()

        home.navigationItem.largeTitleDisplayMode = .always
        profile.navigationItem.largeTitleDisplayMode = .always
        calendarVC.navigationItem.largeTitleDisplayMode = .always

        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: profile)
        let nav3 = UINavigationController(rootViewController: calendarVC)

        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true

        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 3)

        setViewControllers([nav1, nav2, nav3], animated: true)
    }
}
