library AdminController

use HTTP

context AdminController {
    requires: SpringController
}

operation administration() : HT TPResponse {
    precondition: HTTP.method == "GET"
    postcondition: HTTP.responseBody == "administration.html" && 
                   HTTP.status == 200
}

operation workWithCopy() : HTTPResponse {
    precondition: HTTP.method == "GET"
    postcondition: HTTP.responseBody == "workWithCopy.html" && 
                   HTTP.status == 200
}

operation workWithClient() : HTTPResponse {
    precondition: HTTP.method == "GET"
    postcondition: HTTP.responseBody == "workWithClient.html" && 
                   HTTP.status == 200
}

operation workWithEditions() : HTTPResponse {
    precondition: HTTP.method == "GET"
    postcondition: HTTP.responseBody == "workWithEditions.html" && 
                   HTTP.status == 200
}

context Security {
    requires: user.role == "ADMIN"
}
