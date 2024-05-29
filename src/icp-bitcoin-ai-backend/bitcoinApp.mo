import Types "Types";
import Errors "Errors";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Nat32 "mo:base/Nat32";

actor {  
    // Define the ManagementCanisterActor with necessary Bitcoin methods
    type ManagementCanisterActor = actor {
        bitcoin_get_balance: {
            address: Text;
            network: Text;
            min_confirmations: ?Nat32;
        } -> async Errors.Result<Nat, Text>;
    };
    

    // Define the Bitcoin network
    public type Network = {
        #Mainnet;
        #Testnet;
    };

    let management_canister_actor : ManagementCanisterActor = actor("aaaaa-aa");

    // Function to get the balance of a Bitcoin address
    public func get_balance(network: Network, address: Text): async Errors.Result<Nat, Text> {
        let network_text = switch (network) {
            case (#Mainnet) "mainnet";
            case (#Testnet) "testnet";
        };

        // Add cycles for the API call
        ExperimentalCycles.add<system>(10_000_000_000);

        // Make the API call to get the balance
        let balance_result = await management_canister_actor.bitcoin_get_balance({
            address = address;
            network = network_text;
            min_confirmations = null;
        });

        // Return the balance or an error
        switch (balance_result) {
            case (#ok(balance)) { return #ok(balance) };
            case (#err(error_message)) { return #err(error_message) };
        }
    };
};
