import UIKit

class PostPreviewTableViewCell: UITableViewCell {
    static let identifier = "PostPreviewTableViewCell"

    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 292)
    }

    private let spinner = UIActivityIndicatorView(style: .large)

    var currentPostId: Int?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        contentView.clipsToBounds = true

        let distanceLabelContainer = UIStackView()
        distanceLabelContainer.axis = .horizontal
        distanceLabelContainer.distribution = .fill
        distanceLabelContainer.addArrangedSubview(postTitleLabel)
        distanceLabelContainer.addArrangedSubview(distanceLabel)
        distanceLabelContainer.translatesAutoresizingMaskIntoConstraints = false

        let cardContainer = UIView()
        cardContainer.backgroundColor = .clear
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.layer.shadowRadius = 3
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardContainer.layer.shadowOpacity = 0.4

        let borderView = UIView()
        borderView.backgroundColor = .secondarySystemBackground
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.layer.cornerRadius = 12
        borderView.layer.masksToBounds = true

        cardContainer.addSubview(borderView)
        borderView.addSubview(postImageView)
        borderView.addSubview(distanceLabelContainer)
        contentView.addSubview(cardContainer)

        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            borderView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            postImageView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            postImageView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 200),
            distanceLabelContainer.topAnchor.constraint(equalTo: postImageView.bottomAnchor),
            distanceLabelContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 8),
            distanceLabelContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -8),
            distanceLabelContainer.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func addSpinner() {
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor),
        ])

        spinner.startAnimating()
    }

    private func removeSpinner() {
        spinner.removeFromSuperview()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        postTitleLabel.text = nil
        postImageView.image = nil
        currentPostId = nil
        distanceLabel.text = nil
        removeSpinner()
    }

    func configure(with post: Post) {
        postTitleLabel.text = post.title
        currentPostId = post.postId
        let distance = Int.random(in: 10...900)
        distanceLabel.text = "\(distance - distance % 10) m"

        addSpinner()

        NetworkManager.shared.image(post: post) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            guard let self = self else { return }
            guard let currentPostId = self.currentPostId else {
                return
            }

            // Handle async image loading
            // To not update cell if cell was already changed for another post
            if currentPostId == post.postId {
                DispatchQueue.main.async {
                    self.removeSpinner()
                    self.postImageView.image = UIImage(data: data)
                }
            }
        }
    }
}
