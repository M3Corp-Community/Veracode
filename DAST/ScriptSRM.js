var clientId = "XXXXYYYYZZZZ";
var clientSecret = "XXXXYYYYZZZZ";
var subscriptionKey = "XXXXYYYYZZZZ";
var scope = "XXXXYYYYZZZZ";
var apiUrl = "https://mytokengenapi.mycompany.com/private/oauth/v2.0/token";

var bearerToken = null;

function run() {
    if (bearerToken === null) {
        let tokenRequest = createTokenRequest();
        bearerToken = fetchToken(tokenRequest);
    }
    updateRequestHeaders(bearerToken);
}
function createTokenRequest() {
    let tokenRequest = httpClient.createRequest(apiUrl);
    tokenRequest.addHeader("Content-Type", "application/x-www-form-urlencoded");
    tokenRequest.addHeader("Ocp-Apim-Subscription-Key", subscriptionKey);
    let body = "grant_type=client_credentials" +
               "&client_id=" + encodeURIComponent(clientId) +
               "&client_secret=" + encodeURIComponent(clientSecret);
    if (scope && scope !== "") {
        body += "&scope=" + encodeURIComponent(scope);
    }
    tokenRequest.setBody(body);
    tokenRequest.setMethod("POST");
    return tokenRequest;
}
function fetchToken(tokenRequest) {
    let response = tokenRequest.send();
    let message = response.asString();
    vc.log("Token response: " + message);
    try {
        let parsed = JSON.parse(message);
        return parsed.access_token;
    } catch (e) {
        throw "Error parsing token response: " + message;
    }
}
function updateRequestHeaders(token) {
    request.addHeader("Authorization", "Bearer " + token);
    request.addHeader("Ocp-Apim-Subscription-Key", subscriptionKey);
}