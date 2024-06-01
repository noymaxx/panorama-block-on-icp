import Types "./TypesCryptoQuant";
import Errors "./Errors";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Array "mo:base/Array";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import JSON "mo:serde/JSON";

// Actor
actor {
    var ic: Types.IC = actor("aaaaa-aa");
    var host: Text = "api.mempool.space";

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

        ExperimentalCycles.add<system>(230_949_972_000);

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

        let block: ?Types.AddressInfo = from_candid(json_blob);
        switch (block) {
            case (?b) { return #ok(b) };
            case (null) {
                return #err({ message = "Failed to convert JSON to BitcoinBlock" });
            };
        }
    };
};