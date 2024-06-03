import Errors "./Errors";

module Types {
    // Definição do tipo Timestamp
    public type Timestamp = Nat64;

    public type ManagementCanisterActor = actor {
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

};