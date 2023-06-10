//
//   PostDetailsViewController.swift
//  StrongFuture
//
//  Created by Assylzhan Nurlybekuly on 16.04.2023.
//

import UIKit

final class PostDetailsViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private var postDetails: PostDetails?


    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        imageView.image = UIImage(named: "logo3")
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}


struct PostDetails: Decodable {
    let postId: Int
    let title: String
    let description: String
}
