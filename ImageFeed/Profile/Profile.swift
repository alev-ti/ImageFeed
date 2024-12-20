
struct Profile: Decodable {
    let username: String
    let bio: String?
    let firstName: String
    let lastName: String

    func name() -> String {
        return "\(firstName) \(lastName)"
    }

    func loginName() -> String {
        return "@\(username)"
    }
}
