// Importing necessary modules and custom types/errors.
import Types "./TypesMempool";
import Errors "./Errors";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Array "mo:base/Array";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import JSON "mo:serde/JSON";
import Iter "mo:base/Iter";

// Define the actor which contains all state and functions.
actor {
    // State variable to hold the inter-canister reference.
    var ic: Types.IC = actor("aaaaa-aa");

    // Host URL for the API requests.
    var host: Text = "api.mempool.space";

    // State variable to store the current block hash.
    var current_block_hash: Text = "";

    // Public function to transform HTTP responses based on predefined security headers.
    public query func transform(raw: Types.TransformArgs): async Types.CanisterHttpResponsePayload {
        let transformed: Types.CanisterHttpResponsePayload = {
            status = raw.response.status;
            body = raw.response.body;
            headers = [
                { name = "Content-Security-Policy"; value = "default-src 'self'" },
                { name = "Referrer-Policy"; value = "strict-origin" },
                { name = "Permissions-Policy"; value = "geolocation=(self)" },
                { name = "Strict-Transport-Security"; value = "max-age=63072000" },
                { name = "X-Frame-Options"; value = "DENY" },
                { name = "X-Content-Type-Options"; value = "nosniff" }
            ]
        };
        return transformed;
    };

    // Transformation context used in HTTP requests to apply the transform function.
    var transform_context: Types.TransformContext = {
        function = transform;
        context = Blob.fromArray([]);
    };

    // Default headers for outgoing HTTP requests.
    var request_headers = [
        { name = "Host"; value = host # ":443" },
        { name = "User-Agent"; value = "mempool_canister" }
    ];

    // Function to set the current block hash. Updates the state and returns success.
    public func set_block_hash(block_hash: Text) : async Errors.Result<Text, Errors.MempoolError> {
        current_block_hash := block_hash;
        return #ok("Block hash set successfully");
    };

    // Function to fetch information about a specific Bitcoin block using its hash.
    public func get_bitcoin_block_info(): async Errors.Result<Types.BitcoinBlock, Errors.MempoolError> {
        if (current_block_hash == "") {
            return #err({ message = "Block hash not set" });
        };

        let url = "https://" # host # "/api/block/" # current_block_hash;

        // Define the HTTP request parameters.
        let http_request: Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null;
            headers = request_headers;
            body = null;
            method = #get;
            transform = ?transform_context;
        };

        // Add cycles to the canister to pay for the query.
        ExperimentalCycles.add<system>(230_949_972_000);

        // Perform the HTTP request and await the response.
        let http_response: Types.HttpResponsePayload = await ic.http_request(http_request);

        // Convert the response body to text and attempt to parse as JSON.
        let response_body: Blob = Blob.fromArray(http_response.body);
        let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        let json_result = JSON.fromText(decoded_text, null);
        let json_blob = switch (json_result) {
            case (#ok(blob)) { blob };
            case (#err(e)) {
                return #err({ message = "Failed to parse JSON: " # e });
            };
        };

        // Convert the JSON blob to a BitcoinBlock type.
        let block: ?Types.BitcoinBlock = from_candid(json_blob);
        switch (block) {
            case (?b) { return #ok(b) };
            case (null) {
                return #err({ message = "Failed to convert JSON to BitcoinBlock" });
            };
        }
    };

    // Function to fetch multiple blocks by iterating backward from the current block.
    public func fetch_bitcoin_blocks(count : Nat) : async Errors.Result<[Types.BitcoinBlock], Errors.MempoolError> {
        if (current_block_hash == "") {
            return #err({ message = "Block hash not set" });
        };
        var blocks : [Types.BitcoinBlock] = [];
        var current_count = count;

        // Loop through the number of blocks to retrieve, querying one at a time.
        while (current_count > 0) {
            let block_result = await get_bitcoin_block_info();
            switch (block_result) {
                case (#ok(block_data)) {
                    blocks := Array.append(blocks, [block_data]);
                    current_block_hash := block_data.previousblockhash;
                };
                case (#err(error)) {
                    return #err(error);
                };
            };
            current_count -= 1;
        };

        return #ok(blocks);
    };

        // Fetches detailed transaction information for a specific Bitcoin block using its hash.
    public func get_bitcoin_block_transactions_info() : async Errors.Result<Types.Transactions, Errors.MempoolError> {
        // Check if the current block hash has been set, if not, return an error.
        if (current_block_hash == "") {
            return #err({ message = "Block hash not set" });
        };

        // Construct the URL to fetch transaction IDs for the current block.
        let url_txids = "https://api.mempool.space/api/block/" # current_block_hash # "/txids";

        // Prepare the HTTP request parameters for fetching transaction IDs.
        let http_request_txids : Types.HttpRequestArgs = {
            url = url_txids;
            max_response_bytes = null;
            headers = [];
            body = null;
            method = #get;
            transform = null;
        };

        // Add cycles for processing the request.
        ExperimentalCycles.add<system>(230_949_972_000);

        // Execute the HTTP request and await the response.
        let http_response_txids : Types.HttpResponsePayload = await ic.http_request(http_request_txids);

        // Process the HTTP response to extract transaction IDs.
        let response_body_txids : Blob = Blob.fromArray(http_response_txids.body);
        let decoded_text_txids : Text = switch (Text.decodeUtf8(response_body_txids)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        // Parse the JSON response to extract transaction IDs.
        let json_result_txids = JSON.fromText(decoded_text_txids, null);
        let json_blob_txids = switch (json_result_txids) {
            case (#ok(blob)) { blob };
            case (#err(e)) {
                return #err({ message = "Failed to parse JSON: " # e });
            };
        };

        // Convert the JSON blob to a Transactions type.
        let txids : ?Types.Transactions = from_candid(json_blob_txids);
        switch (txids) {
            case (?t) { return #ok(t) };
            case (null) {
                return #err({ message = "Failed to convert JSON to [Text]" });
            };
        };
    };

    // Fetches detailed information for a specific Bitcoin transaction using its transaction ID.
    public func get_bitcoin_transaction_info(txid : Text) : async Errors.Result<?Text, Errors.MempoolError> {
        // Construct the URL for fetching details of a specific transaction.
        let url_tx = "https://api.mempool.space/api/tx/" # txid;

        // Prepare the HTTP request parameters for the transaction.
        let http_request_tx : Types.HttpRequestArgs = {
            url = url_tx;
            max_response_bytes = null;
            headers = request_headers;
            body = null;
            method = #get;
            transform = ?transform_context;
        };

        // Add cycles to fund the operation.
        ExperimentalCycles.add<system>(230_949_972_000);

        // Execute the HTTP request and handle the response.
        let http_response_tx : Types.HttpResponsePayload = await ic.http_request(http_request_tx);

        // Check if the response body is empty and return an error if so.
        if (http_response_tx.body.size() == 0) {
            return #err({ message = "Empty response body" });
        };

        // Decode and parse the JSON response to extract transaction information.
        let response_body_tx : Blob = Blob.fromArray(http_response_tx.body);
        let jsonText : Text = switch (Text.decodeUtf8(response_body_tx)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        return #ok(?jsonText);        
    };

    // Aggregates transaction details for multiple transactions identified by their IDs.
    public func fetch_transactions(): async Errors.Result<[?Text], Errors.MempoolError> {
        // Fetch transaction IDs for the current block.
        let txids_result = await get_bitcoin_block_transactions_info();

        switch (txids_result) {
            case (#ok(txids)) {
                // Process each transaction ID to fetch and accumulate their details.
                func processTxids(txids: [Text], index: Nat, accum: [?Text]): async [?Text] {
                    // Base case: if all transaction IDs have been processed, return the accumulated results.
                    if (index == txids.size()) {
                        return accum;
                    } else {
                        // Recursive case: fetch transaction info for the current ID and proceed to the next.
                        let tx_result = await get_bitcoin_transaction_info(txids[index]);
                        let processed_result: ?Text = switch (tx_result) {
                            case (#ok(text)) { text };
                            case (#err(_)) { null };
                        };
                        return await processTxids(txids, index + 1, Array.append(accum, [processed_result]));
                    };
                };
                // Start processing transactions from the first ID.
                let transactions_details = await processTxids(txids, 0, []);
                return #ok(transactions_details);
            };
            case (#err(e)) {
                return #err(e);
            };
        };
    };

    // Fetches detailed information about a specific Bitcoin address.
    public func get_address_info(address: Text): async Errors.Result<Types.AddressInfo, Errors.MempoolError> {
        // Construct the URL for fetching address details.
        let url = "https://" # host # "/api/address/" # address;

        // Prepare the HTTP request parameters for the address query.
        let http_request: Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null;
            headers = request_headers;
            body = null;
            method = #get;
            transform = ?transform_context;
        };

        // Allocate system cycles for the query.
        ExperimentalCycles.add<system>(230_949_972_000);

        // Execute the HTTP request and handle the response.
        let http_response: Types.HttpResponsePayload = await ic.http_request(http_request);

        // Process the response to extract address information.
        let response_body: Blob = Blob.fromArray(http_response.body);
        let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        // Parse the JSON response to extract detailed address information.
        let json_result = JSON.fromText(decoded_text, null);
        let json_blob = switch (json_result) {
            case (#ok(blob)) { blob };
            case (#err(e)) {
                return #err({ message = "Failed to parse JSON: " # e });
            };
        };

        // Convert the JSON blob to an AddressInfo type.
        let addressInfo: ?Types.AddressInfo = from_candid(json_blob);
        switch (addressInfo) {
            case (?a) { return #ok(a) };
            case (null) {
                return #err({ message = "Failed to convert JSON to AddressInfo" });
            };
        };
    };
};
