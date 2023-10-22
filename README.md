# Simple Weather forecast service // server & consumer

This is an exercise project utilising API model definition, mock server using it (for contract testing) and a consumer golang application.

## Tools

I've used smithy to define the API model (including examples). Then with the help of smithy-cli generated an OpenAPI specification and used that with Prism tool to launch a mock server (with docker). Then wrote a basic golang application that would drain all the results (I've defined 3) from the paginated API response, join them and emit a response for every one of them on a new line.

## Why?

I've recently had an interview and this golang app was one of the tasks. I couldn't finish it on time, so I figured I'd do it properly and add the server (mock) part as well.

## How to use this?

Smithy model is built simply by running `smithy build model/` (or `smithy-cli build model/`, depending on how you install it). That generates the OpenAPI spec in `build/source/openapi/Weather.openapi.json`. If you don't have `smithy-cli`, you can install it with homebrew or download an executable for your OS from https://github.com/smithy-lang/smithy/releases.

```
$ smithy build model/

SUCCESS: Validated 332 shapes

Validated model, now starting projections...

──  source  ────────────────────────────────────────────────────────────────────
Completed projection source (332): /path/to/this/repository/build/smithy/source

Summary: Smithy built 1 projection(s), 4 plugin(s), and 6 artifacts
```

Then you can launch Prism Mock server: `docker run --init -p 4010:4010 -v $(pwd)/build/smithy/source/openapi:/tmp/ stoplight/prism:4 mock -h 0.0.0.0 /tmp/Weather.openapi.json`.

Wait until you see the mock server is up & running:

```
[9:41:38 PM] › [CLI] …  awaiting  Starting Prism…
[9:41:45 PM] › [CLI] ✔  success   GET        http://0.0.0.0:4010/forecast?cityId=all&page=3&per_page=45
[9:41:45 PM] › [CLI] ✔  success   Prism is listening on http://0.0.0.0:4010
```

Now you can experiment with `go run main.go`:

```
go run main.go 
Dallas, 12, 2, 5
Dallupura, 10, 9, 14
Vallejo, 1, 24, 56
Montreal, 17, 42, 10
Sofia, 25, 1, 15
Varna, 30, 2, 62
Chicago, 23, 8, 5
```

In the Prism terminal window, you will see the following log output:

```
[9:41:50 PM] › [HTTP SERVER] get /forecast ✔  success   Request received
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Request contains an accept header: application/json
[9:41:50 PM] ›     [VALIDATOR] ✔  success   The request passed the validation rules. Looking for the best response
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Found a compatible content for application/json
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Responding with the requested status code 200
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   > Responding with "200"
[9:41:50 PM] › [HTTP SERVER] get /forecast ✔  success   Request received
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Request contains an accept header: application/json
[9:41:50 PM] ›     [VALIDATOR] ✔  success   The request passed the validation rules. Looking for the best response
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Found a compatible content for application/json
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Responding with the requested status code 200
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   > Responding with "200"
[9:41:50 PM] › [HTTP SERVER] get /forecast ✔  success   Request received
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Request contains an accept header: application/json
[9:41:50 PM] ›     [VALIDATOR] ✔  success   The request passed the validation rules. Looking for the best response
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Found a compatible content for application/json
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   Responding with the requested status code 200
[9:41:50 PM] ›     [NEGOTIATOR] ✔  success   > Responding with "200"
```

### Extra notes

I didn't pick Prism randomly. I've actually selected it, because of a very powerful feature - dynamic response generation, based on the API definition. You can try that with the `-d` flag: `docker run --init -p 4010:4010 -v $(pwd)/build/smithy/source/openapi:/tmp/ stoplight/prism:4 mock -h 0.0.0.0 /tmp/Weather.openapi.json -d`

Some interesting results would come out of this. Definitely helped in defining the API spec better and also catching some weird edge cases with the client golang app.
