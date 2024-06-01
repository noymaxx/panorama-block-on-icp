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

    public type ChainStats = {
    funded_txo_count : Nat;
    funded_txo_sum : Nat;
    spent_txo_count : Nat;
    spent_txo_sum : Nat;
    tx_count : Nat;
  };

    public type MempoolStats = {
        funded_txo_count : Nat;
        funded_txo_sum : Nat;
        spent_txo_count : Nat;
        spent_txo_sum : Nat;
        tx_count : Nat;
    };

    public type AddressInfo = {
        address : Text;
        chain_stats : ChainStats;
        mempool_stats : MempoolStats;
    };

    
};