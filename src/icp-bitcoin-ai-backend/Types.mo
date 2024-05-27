module Types {
    // Definição do tipo Timestamp
    public type Timestamp = Nat64;

    // Definições de tipos relacionados à requisição HTTPS
    public type HttpRequestArgs = {
        url : Text;
        max_response_bytes : ?Nat64;
        headers : [HttpHeader];
        body : ?[Nat8];
        method : HttpMethod;
        transform : ?TransformRawResponseFunction;
    };

    public type HttpHeader = {
        name : Text;
        value : Text;
    };

    public type HttpMethod = {
        #get;
        #post;
        #head;
    };

    public type HttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

    public type TransformRawResponseFunction = {
        function : shared query TransformArgs -> async HttpResponsePayload;
        context : Blob;
    };

    public type TransformArgs = {
        response : HttpResponsePayload;
        context : Blob;
    };

    public type CanisterHttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

    public type TransformContext = {
        function : shared query TransformArgs -> async HttpResponsePayload;
        context : Blob;
    };

    public type IC = actor {
        http_request : HttpRequestArgs -> async HttpResponsePayload;
    };

    public type BitcoinBlock = {
        id : Text;
        height : Nat;
        version : Nat;
        timestamp : Nat;
        bits : Nat;
        nonce : Nat;
        difficulty : Float;
        merkle_root : Text;
        tx_count : Nat;
        size : Nat;
        weight : Nat;
        previousblockhash : Text;
    };

    public type BitcoinTransaction = {
        txid: [Text];
    };

    public type JsonOptions = {
        renameKeys : ?[None];
        use_icrc_3_value_type : Bool;
    };
};