import Foundation

enum NetworkManagerError: Error {
  case badResponse(URLResponse?)
  case badData
  case badLocalUrl
}


class NetworkManager {

    static var shared = NetworkManager()

    private var images = NSCache<NSString, NSData>()

    let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }

    func posts(completion: @escaping ([Post]?, Error?) -> (Void)) {
        guard let url = URL(string: "https://mocki.io/v1/1542c26c-325e-40ae-8a60-2e7db72ed0d4") else {
            completion(nil,nil)
            return
        }
        let req = URLRequest(url: url)

        let task = session.dataTask(with: req) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NetworkManagerError.badResponse(response))
                return
            }

            guard let data = data else {
                completion(nil, NetworkManagerError.badData)
                return
            }

            do {
                let response = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                    completion(response, nil)
                }
            } catch let error {
                completion(nil, error)
            }
        }

        task.resume()
    }

    private func download(imageURL: URL, completion: @escaping (Data?, Error?) -> (Void)) {
        if let imageData = images.object(forKey: imageURL.absoluteString as NSString) {
            print("using cached images")
            completion(imageData as Data, nil)
            return
        }

        let task = session.downloadTask(with: imageURL) { localUrl, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NetworkManagerError.badResponse(response))
                return
            }

            guard let localUrl = localUrl else {
                completion(nil, NetworkManagerError.badLocalUrl)
                return
            }

            do {
                let data = try Data(contentsOf: localUrl)
                self.images.setObject(data as NSData, forKey: imageURL.absoluteString as NSString)
                completion(data, nil)
            } catch let error {
                completion(nil, error)
            }
        }

        task.resume()
    }

    func image(post: Post, completion: @escaping (Data?, Error?) -> (Void)) {
        let url = URL(string: post.image)!
        download(imageURL: url, completion: completion)
    }
}

struct Post: Decodable {
    let title: String
    let postId: Int
    let image: String
}
