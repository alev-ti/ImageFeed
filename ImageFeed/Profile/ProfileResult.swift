
struct ProfileResult: Decodable {
    let username: String
    let bio: String?
    let firstName: String
    let lastName: String

    func toProfile() -> Profile {
        return Profile(username: username, bio: bio, firstName: firstName, lastName: lastName)
    }
}
