import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let apiKey = "146640ab645a4aacb128ff97a63ecb6f" // Replace with your NewsAPI key
        static let baseURL = "https://newsapi.org/v2/top-headlines"
        static let country = "us"
        static let category = "business"
        
        static var topHeadlinesURL: URL? {
            var components = URLComponents(string: baseURL)
            components?.queryItems = [
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "category", value: category),
                URLQueryItem(name: "apiKey", value: apiKey)
            ]
            return components?.url
        }
    }
    
    private init() {}
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Networking Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("HTTP Error: \(httpResponse.statusCode)")
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])))
                return
            }
            
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Fetched \(result.articles.count) articles")
                    completion(.success(result.articles))
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

struct APIResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Codable {
    let name: String
}
