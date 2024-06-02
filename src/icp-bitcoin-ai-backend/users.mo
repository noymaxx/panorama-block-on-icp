import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Errors "Errors";

// Definição do tipo UserType
type UserType = {
    id: Nat;
    name: Text;
};

actor User {
    stable var users: [UserType] = [];
    stable var nextUserId: Nat = 0;

    public func addUser(name: Text): async () {
        let newUser: UserType = {
            id = nextUserId;
            name = name;
        };
        users := Array.append(users, [newUser]);
        nextUserId += 1;
    };

    public query func listUsers(): async [UserType] {
        return users;
    };

    public query func getUserCanisterId(): async Principal {
        return Principal.fromActor(User);
    }
};
