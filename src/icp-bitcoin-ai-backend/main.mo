import Types "Types";
import Errors "Errors";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Array "mo:base/Array";
import Text "mo:base/Text";
import JSON "mo:serde/JSON";

// Actor
actor {

    var ic : Types.IC = actor ("aaaaa-aa");
    var host : Text = "api.mempool.space";
    
    // Function to transform the response
    public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
        let transformed : Types.CanisterHttpResponsePayload = {
            status = raw.response.status;
            body = raw.response.body;
            headers = [
                {
                    name = "Content-Security-Policy";
                    value = "default-src 'self'";
                },
                { name = "Referrer-Policy"; value = "strict-origin" },
                { name = "Permissions-Policy"; value = "geolocation=(self)" },
                {
                    name = "Strict-Transport-Security";
                    value = "max-age=63072000";
                },
                { name = "X-Frame-Options"; value = "DENY" },
                { name = "X-Content-Type-Options"; value = "nosniff" },
            ];
        };
        return transformed;
    };

    var transform_context : Types.TransformContext = {
          function = transform;
          context = Blob.fromArray([]);
        };

    var request_headers = [
            { name = "Host"; value = host # ":443" },
            { name = "User-Agent"; value = "exchange_rate_canister" },
        ];

    public func get_bitcoin_block(block_hash : Text) : async Errors.Result<Types.BitcoinBlock, Errors.MempoolError> {
        let url = "https://" # host # "/api/block/" # block_hash;

        let http_request : Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null; // optional for request
            headers = request_headers;
            body = null; // optional for request
            method = #get;
            transform = ?transform_context;
        };

        Cycles.add(1_603_128_800);

        let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);

        let response_body: Blob = Blob.fromArray(http_response.body);
        let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?y) { y };
        }; 

        let json_result = JSON.fromText(decoded_text, null);
        let json_blob = switch (json_result) {
            case (#ok(blob)) { blob };
            case (#err(e)) { return #err({message = "Failed to parse JSON: " # e}) };
        };

        let block : ?Types.BitcoinBlock = from_candid(json_blob);
        switch (block) {
            case (?b) { return #ok(b) };
            case (null) { return #err({message = "Failed to convert JSON to BitcoinBlock"}) };
        };
    };

    public func fetch_last_blocks(block_hash : Text, count : Nat) : async Errors.Result<[Types.BitcoinBlock], Errors.MempoolError> {
      var current_hash = block_hash;
      var blocks : [Types.BitcoinBlock] = [];
      
      var current_count = count;
      while (current_count > 0) {
        let block_result = await get_bitcoin_block(current_hash);
        switch (block_result) {
            case (#ok(block_data)) {
                blocks := Array.append(blocks, [block_data]);
                current_hash := block_data.previousblockhash;
            };
            case (#err(error)) {
                return #err(error);
            };
        };
        current_count -= 1;
      };

      return #ok(blocks);
    };

    public func get_bitcoin_block_txids(block_hash : Text) : async Errors.Result<Text, Errors.MempoolError> {
        let url_txids = "https://api.mempool.space/api/block/" # block_hash # "/txids";

        let http_request_txids : Types.HttpRequestArgs = {
            url = url_txids;
            max_response_bytes = null;
            headers = request_headers;
            body = null;
            method = #get;
            transform = ?transform_context;
        };

        Cycles.add(1_603_128_800);

        let http_response_txids : Types.HttpResponsePayload = await ic.http_request(http_request_txids);

        let response_body_txids: Blob = Blob.fromArray(http_response_txids.body);
        let decoded_text_txids: Text = switch (Text.decodeUtf8(response_body_txids)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        let txids : Text = decoded_text_txids;

        return #ok(txids);
    };

    public func get_bitcoin_tx(txid : Text) : async Errors.Result<Types.BitcoinTx, Errors.MempoolError> {
        let url_tx = "https://api.mempool.space/api/tx/" # txid;

        let http_request_tx : Types.HttpRequestArgs = {
            url = url_tx;
            max_response_bytes = null;
            headers = request_headers;
            body = null;
            method = #get;
            transform = ?transform_context;
        };

        Cycles.add(1_603_128_800);

        let http_response_tx : Types.HttpResponsePayload = await ic.http_request(http_request_tx);

        // Check if the response body is not empty
        if (http_response_tx.body.size() == 0) {
            return #err({message = "Empty response body"});
        };

        let response_body_tx: Blob = Blob.fromArray(http_response_tx.body);
        let decoded_text_tx: Text = switch (Text.decodeUtf8(response_body_tx)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };
        
        Debug.print("Decoded text: " # decoded_text_tx);

        let json_result_tx = JSON.fromText(decoded_text_tx, null);
        let json_blob_tx = switch (json_result_tx) {
            case (#ok(blob)) { blob };
            case (#err(e)) { return #err({message = "Failed to parse JSON: " # e}) };
        };

        let tx : ?Types.BitcoinTx = from_candid(json_blob_tx);
        switch (tx) {
            case (?b) { return #ok(b) };
            case (null) { return #err({message = "Failed to convert JSON to BitcoinTx"}) };
        };
    };
};