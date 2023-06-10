import UIKit
import SwiftUI

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Profile Photo

    // Full Name

    // Email

    // List of posts

    private var user: User?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self,
                           forCellReuseIdentifier: PostPreviewTableViewCell.identifier)
        return tableView
    }()

    let currentEmail: String
    let currentName: String
    let currentPhone: String

    init(currentEmail: String, currentName: String, currentPhone: String) {
        self.currentEmail = currentEmail
        self.currentName = currentName
        self.currentPhone = currentPhone
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSignOutButton()
        setUpTable()
        title = "Profile"
        fetchPosts()
        

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpTableHeader()
        fetchProfileData()
        setUpRecommendButton()
    }

    private func setUpTableHeader(
        profilePhotoRef: String? = nil,
        name: String? = nil
    ) {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/3))
        headerView.backgroundColor = .systemBlue
        headerView.isUserInteractionEnabled = true
        headerView.clipsToBounds = true
        tableView.tableHeaderView = headerView

        // Profile picture
        let profilePhoto = UIImageView(image: UIImage(systemName: "person.circle"))
        profilePhoto.tintColor = .white
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.frame = CGRect(
            x: (view.width-(view.width/4))/2,
            y: (headerView.height-(view.width/4))/2.5,
            width: view.width/4,
            height: view.width/4
        )
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.cornerRadius = profilePhoto.width/2
        profilePhoto.isUserInteractionEnabled = true
        headerView.addSubview(profilePhoto)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
        profilePhoto.addGestureRecognizer(tap)

        // Email


        if let name = name {
            title = name
        }

        if let ref = profilePhotoRef {
            // Fetch image
            StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
                guard let url = url else {
                    return
                }
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {
                        return
                    }
                    DispatchQueue.main.async {
                        profilePhoto.image = UIImage(data: data)
                    }
                }

                task.resume()
            }
        }
    }

    private func setUpRecommendButton(){
        
        let profileView = UIView(frame: CGRect(x: 0, y: view.width/3, width: view.width, height: view.height*0.55))
        
        let nameLabel = UILabel(frame: CGRect(x: view.width*0.05, y: 10, width: view.width-40, height: 25))
        profileView.addSubview(nameLabel)
        nameLabel.text = "Name:"
        //emailLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        let name = UILabel(frame: CGRect(x: view.width*0.05, y: 35, width: view.width-40, height: 25))
        profileView.addSubview(name)
        name.text = currentName
        //emailLabel.textAlignment = .center
        name.font = .systemFont(ofSize: 20)
        
        let divider = UIView(frame: CGRect(x: view.width*0.05, y: 70, width: view.width*0.9, height: 0.5))
        divider.backgroundColor = .blue
        profileView.addSubview(divider)
        
        let phoneLabel = UILabel(frame: CGRect(x: view.width*0.05, y: 80, width: view.width-40, height: 25))
        profileView.addSubview(phoneLabel)
        phoneLabel.text = "Phone Number:"
        //phoneLabel.textAlignment = .center
        phoneLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        let phone = UILabel(frame: CGRect(x: view.width*0.05, y: 105, width: view.width-40, height: 25))
        profileView.addSubview(phone)
        phone.text = currentPhone
        //emailLabel.textAlignment = .center
        phone.font = .systemFont(ofSize: 20)
        
        let divider1 = UIView(frame: CGRect(x: view.width*0.05, y: 140, width: view.width*0.9, height: 0.5))
        divider1.backgroundColor = .blue
        profileView.addSubview(divider1)
        
        let emailLabel = UILabel(frame: CGRect(x: view.width*0.05, y: 150, width: view.width-40, height: 25))
        profileView.addSubview(emailLabel)
        emailLabel.text = "Email:"
        //yearLabel.textAlignment = .center
        emailLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        let email = UILabel(frame: CGRect(x: view.width*0.05, y: 175, width: view.width-40, height: 25))
        profileView.addSubview(email)
        email.text = currentEmail
        //emailLabel.textAlignment = .center
        email.font = .systemFont(ofSize: 20)
        
 
        //recommendView.backgroundColor = .systemCyan
        let button = UIButton(frame: CGRect(x: view.width/6, y: view.height*0.45, width: view.width/1.4, height: view.width/6))
        button.setTitle("Survey for Recommendation", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.backgroundColor = .systemCyan
        // Add the button as a subview
        profileView.addSubview(button)
        
        
        tableView.tableFooterView = profileView
    }

    @objc private func didTapProfilePhoto() {
        guard let myEmail = UserDefaults.standard.string(forKey: "email"),
              myEmail == currentEmail else {
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    private func fetchProfileData() {
        DatabaseManager.shared.getUser(email: currentEmail) { [weak self] user in
            guard let user = user else {
                return
            }
            self?.user = user

            DispatchQueue.main.async {
                self?.setUpTableHeader(
                    profilePhotoRef: user.profilePictureRef,
                    name: user.name
                )
            }
        }
    }

    private func setUpSignOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sign Out",
            style: .done,
            target: self,
            action: #selector(didTapSignOut)
        )
    }

    /// Sign Out
    @objc private func didTapSignOut() {
        let sheet = UIAlertController(title: "Sign Out", message: "Are you sure you'd like to sign out?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(nil, forKey: "email")
                        UserDefaults.standard.set(nil, forKey: "name")
                        UserDefaults.standard.set(false, forKey: "premium")

                        let signInVC = SignInViewController()
                        signInVC.navigationItem.largeTitleDisplayMode = .always

                        let navVC = UINavigationController(rootViewController: signInVC)
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: nil)
                    }
                }
            }
        }))
        present(sheet, animated: true)
    }

    // TableView

    private var posts: [BlogPost] = []

    private func fetchPosts() {
        print("Fetching posts...")

        DatabaseManager.shared.getPosts(for: currentEmail) { [weak self] posts in
            self?.posts = posts
            print("Found \(posts.count) posts")
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let post = posts[indexPath.row]
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewTableViewCell.identifier, for: indexPath) as? PostPreviewTableViewCell else {
//            fatalError()
//        }
//        cell.configure(with: .init(title: post.title, imageUrl: post.headerImageUrl))
//        return cell
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        HapticsManager.shared.vibrateForSelection()

        // TO DO: Selected post
    }

    @objc func buttonTapped() {
        // Create a new instance of your SwiftUI view
        let swiftUIView = RecommendationForm()

        // Wrap the SwiftUI view in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)

        // Present the hosting controller modally
        present(hostingController, animated: true, completion: nil)
    }

    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }

        StorageManager.shared.uploadUserProfilePicture(
            email: currentEmail,
            image: image
        ) { [weak self] success in
            guard let strongSelf = self else { return }
            if success {
                // Update database
                DatabaseManager.shared.updateProfilePhoto(email: strongSelf.currentEmail) { updated in
                    guard updated else {
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.fetchProfileData()
                    }
                }
            }
        }
    }
}
