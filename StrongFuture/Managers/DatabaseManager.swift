
import Foundation

final class DatabaseManager {
    static let shared = DatabaseManager()

//    private let database = Firestore.firestore()

    private init() {}

    // TO DO:
    public func insert(
        blogPost: BlogPost,
        email: String,
        completion: @escaping (Bool) -> Void
    ) {}

    // TO DO:
    public func getAllPosts(
        completion: @escaping ([BlogPost]) -> Void
    ) {}

    // TO DO:
    public func getPosts(
        for email: String,
        completion: @escaping ([BlogPost]) -> Void
    ) {}

    // TO DO:
    public func insert(
        user: User,
        completion: @escaping (Bool) -> Void
    ) {}

    // TO DO:
    public func getUser(
        email: String,
        completion: @escaping (User?) -> Void
    ) {}


    // TO DO:
    func updateProfilePhoto(
        email: String,
        completion: @escaping (Bool) -> Void
    ) {}
}
