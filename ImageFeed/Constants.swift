import Foundation

enum Constants {
    static let accessKey = "afF059dWAqOpSCIVHfixQH4kA-PIQ4OlXZeaoun4kIA"
    static let secretKey = "CsN49H-ONaBOYq_w5SSt0sp9lwUC9L_itNTYocCJ3Ow"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"

    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL for defaultBaseURL")
        }
        return url
    }()
}
