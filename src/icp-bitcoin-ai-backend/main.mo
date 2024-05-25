import Types "Types";
import Errors "Errors";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Result "mo:base/Result";

// Actor
actor {

    var ic : Types.IC = actor ("aaaaa-aa");
    var block_hash : Text = "00000000000000000007566f8f035a1dc38b351e6f54778b311fe6dbabd79b46";
    var host : Text = "api.mempool.space";
    
    //function to transform the response
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

    public func get_bitcoin_block() : async Errors.Result<Types.BitcoinBlock, Errors.MempoolError> {
        let url = "https://" # host # "/api/block/" # block_hash;

        let http_request : Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null; //optional for request
            headers = request_headers;
            body = null; //optional for request
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

        let block : Types.BitcoinBlock = {
            id = "00000000000000000007566f8f035a1dc38b351e6f54778b311fe6dbabd79b46";
            height = 736941;
            version = 536870916;
            timestamp = 1652891466;
            bits = 386466234;
            nonce = 3514220842;
            difficulty = 31251101365711;
            merkle_root = "4a3072f98f60cbb639bb7f46180b8843d17c7502627ffb633db0ed86610cdd71";
            tx_count = 2381;
            size = 1709571;
            weight = 3997770;
            previousblockhash = "00000000000000000005ef14db0b4befcbbe1e9b8676eec67fcf810a899c4d5e";
        };

        return #ok(block);
    };

    public func get_bitcoin_block_txids() : async Errors.Result<Text, Errors.MempoolError> {
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
};
