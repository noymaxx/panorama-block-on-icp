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

actor {
    var ic: Types.IC = actor("aaaaa-aa");
    var host: Text = "api.mempool.space";
    var current_block_hash: Text = "";
    
    stable var stableBlocks: [Types.BitcoinBlock] = [];

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

    var transform_context: Types.TransformContext = {
        function = transform;
        context = Blob.fromArray([]);
    };

    var request_headers = [
        { name = "Host"; value = host # ":443" },
        { name = "User-Agent"; value = "mempool_canister" }
    ];

    public func set_block_hash(block_hash: Text) : async Errors.Result<Text, Errors.MempoolError> {
        current_block_hash := block_hash;
        return #ok("Block hash set successfully");
    };

    public func get_bitcoin_block_info(): async Errors.Result<Types.BitcoinBlock, Errors.MempoolError> {
        if (current_block_hash == "") {
            return #err({ message = "Block hash not set" });
        };

        let url = "https://" # host # "/api/block/" # current_block_hash;

        let http_request: Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null;
            headers = request_headers;
            body = null;
            method = #get;
            transform = ?transform_context;
        };

        Cycles.add<system>(1_603_124_000);

        let http_response: Types.HttpResponsePayload = await ic.http_request(http_request);

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

        let block: ?Types.BitcoinBlock = from_candid(json_blob);
        switch (block) {
            case (?b) { return #ok(b) };
            case (null) {
                return #err({ message = "Failed to convert JSON to BitcoinBlock" });
            };
        }
    };

    public func fetch_bitcoin_blocks(count: Nat) : async Errors.Result<[Types.BitcoinBlock], Errors.MempoolError> {
        if (current_block_hash == "") {
            return #err({ message = "Block hash not set" });
        };
        var blocks : [Types.BitcoinBlock] = [];
        var current_count = count;
        var block_hash = current_block_hash;

        while (current_count > 0 and block_hash != "") {
            let block_result = await get_bitcoin_block_info();
            switch (block_result) {
                case (#ok(block_data)) {
                    blocks := Array.append(blocks, [block_data]);
                    block_hash := block_data.previousblockhash;
                    current_block_hash := block_data.previousblockhash; // Update the current_block_hash for next call
                };
                case (#err(error)) {
                    return #err(error);
                };
            };
            current_count -= 1;
        };

        stableBlocks := Array.append(stableBlocks, blocks); // Append the fetched blocks to stable variable
        return #ok(blocks);
    };

    public func fetch_blocks_queue(count: Nat) : async Errors.Result<[Types.BitcoinBlock], Errors.MempoolError> {
        var all_blocks : [Types.BitcoinBlock] = [];
        var remaining_count = count;
        var block_hash = current_block_hash;

        while (remaining_count > 0 and block_hash != "") {
            let blocks_result = await fetch_bitcoin_blocks(1);
            switch (blocks_result) {
                case (#ok(blocks)) {
                    if (blocks.size() > 0) {
                        let last_block = blocks[blocks.size() - 1];
                        all_blocks := Array.append(all_blocks, blocks);
                        block_hash := last_block.previousblockhash;
                        current_block_hash := last_block.previousblockhash; // Update the current_block_hash for next call
                        remaining_count -= 1;
                    } else {
                        return #err({ message = "No blocks fetched" });
                    };
                };
                case (#err(error)) {
                    return #err(error);
                };
            };
        };

        return #ok(all_blocks);
    };

    public func get_bitcoin_block_transactions() : async Errors.Result<Types.Transactions, Errors.MempoolError> {
        if (current_block_hash == "") {
            return #err({ message = "Block hash not set" });
        };
        let url_txids = "https://api.mempool.space/api/block/" # current_block_hash # "/txids";

        let http_request_txids : Types.HttpRequestArgs = {
            url = url_txids;
            max_response_bytes = null;
            headers = [];
            body = null;
            method = #get;
            transform = null;
        };

        Cycles.add<system>(1_603_124_000);

        let http_response_txids : Types.HttpResponsePayload = await ic.http_request(http_request_txids);

        let response_body_txids : Blob = Blob.fromArray(http_response_txids.body);
        let decoded_text_txids : Text = switch (Text.decodeUtf8(response_body_txids)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        let json_result_txids = JSON.fromText(decoded_text_txids, null);
        let json_blob_txids = switch (json_result_txids) {
            case (#ok(blob)) { blob };
            case (#err(e)) {
                return #err({ message = "Failed to parse JSON: " # e });
            };
        };

        let txids : ?Types.Transactions = from_candid(json_blob_txids);
        switch (txids) {
            case (?t) { return #ok(t) };
            case (null) {
                return #err({ message = "Failed to convert JSON to [Text]" });
            };
        };
    };

    public func get_bitcoin_transaction_info(txid : Text) : async Errors.Result<?Text, Errors.MempoolError> {

        let url_tx = "https://api.mempool.space/api/tx/" # txid;

        let http_request_tx : Types.HttpRequestArgs = {
            url = url_tx;
            max_response_bytes = null;
            headers = request_headers;
            body = null;
            method = #get;
            transform = ?transform_context;
        };

        Cycles.add<system>(1_603_124_000);

        let http_response_tx : Types.HttpResponsePayload = await ic.http_request(http_request_tx);

        if (http_response_tx.body.size() == 0) {
            return #err({ message = "Empty response body" });
        };

        let response_body_tx : Blob = Blob.fromArray(http_response_tx.body);
        let jsonText : Text = switch (Text.decodeUtf8(response_body_tx)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        return #ok(?jsonText);        
    };

    public func fetch_transactions(): async Errors.Result<[?Text], Errors.MempoolError> {
        let txids_result = await get_bitcoin_block_transactions();

        switch (txids_result) {
            case (#ok(txids)) {
                func processTxids(txids: [Text], index: Nat, accum: [?Text]): async [?Text] {
                    if (index == txids.size()) {
                        return accum;
                    } else {
                        let tx_result = await get_bitcoin_transaction_info(txids[index]);
                        let processed_result: ?Text = switch (tx_result) {
                            case (#ok(text)) { text };
                            case (#err(_)) { null };
                        };
                        return await processTxids(txids, index + 1, Array.append(accum, [processed_result]));
                    };
                };
                let transactions_details = await processTxids(txids, 0, []);
                return #ok(transactions_details);
            };
            case (#err(e)) {
                return #err(e);
            };
        };
    };

    public func get_address_info(address: Text): async Errors.Result<Types.AddressInfo, Errors.MempoolError> {
        let url = "https://" # host # "/api/address/" # address;

        let http_request: Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null;
            headers = request_headers;
            body = null;
            method = #get;
            transform = ?transform_context;
        };

        Cycles.add<system>(1_603_124_000);

        let http_response: Types.HttpResponsePayload = await ic.http_request(http_request);

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

        let addressInfo: ?Types.AddressInfo = from_candid(json_blob);
        switch (addressInfo) {
            case (?a) { return #ok(a) };
            case (null) {
                return #err({ message = "Failed to convert JSON to AddressInfo" });
            };
        };
    };

    // Pre-upgrade hook
    system func preupgrade() {
        Debug.print("Executing preupgrade...");
    };

    // Post-upgrade hook
    system func postupgrade() {
        Debug.print("Executing postupgrade...");
    };

    // Reset memory function
    public func reset_memory(): async Errors.Result<Text, Errors.MempoolError> {
        stableBlocks := [];
        return #ok("Memory reset successfully");
    };

    // Function to get the stable blocks
    public query func get_stable_blocks(): async Errors.Result<[Types.BitcoinBlock], Errors.MempoolError> {
        return #ok(stableBlocks);
    };
};
