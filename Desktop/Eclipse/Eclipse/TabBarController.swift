import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let homeVC = createNavController(viewController: HomeViewController(), title: "Home", imageName: "magnifyingglass")
        let rentVC = createNavController(viewController: RentHomeViewController(), title: "Rent", imageName: "cart.fill")
        let libraryVC = createNavController(viewController: LibraryViewController(), title: "Library", imageName: "books.vertical.fill")
        let profileVC = createNavController(viewController: ProfileViewController(), title: "Profile", imageName: "person.fill")

        viewControllers = [homeVC, rentVC, libraryVC, profileVC]
    }

    private func createNavController(viewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        viewController.view.backgroundColor = .white
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: imageName), tag: 0)
        return navController
    }
}

