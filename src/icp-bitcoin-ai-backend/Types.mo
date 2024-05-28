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

    public type BitcoinTxStatus = {
        confirmed: Bool;
        block_height: Nat;
        block_hash: Text;
        block_time: Nat;
    };

    // Estrutura para a entrada da transação
    public type BitcoinTxInput = {
        txid: Text;
        vout: Nat;
        scriptsig: {
            scriptsig_asm: Text;
            scriptsig_hex: Text;
        };
        sequence: Nat;
    };

    // Estrutura para a saída da transação
    public type BitcoinTxOutput = {
        value: Nat;
        n: Nat;
        scriptpubkey: {
            scriptpubkey_asm: Text;
            scriptpubkey_hex: Text;
            scriptpubkey_reqSigs: ?Nat;
            scriptpubkey_type: Text;
            scriptpubkey_address: [Text];
        };
    };

    public type BitcoinTx = {
        txid: Text;
        version: Int;
        locktime: Nat;
        vin: [BitcoinTxInput];
        vout: [BitcoinTxOutput];
        size: Nat;
        weight: Nat;
        fee: Nat;
        status: BitcoinTxStatus;
    };

    public type JsonOptions = {
        renameKeys : ?[None];
        use_icrc_3_value_type : Bool;
    };
};