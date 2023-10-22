$version: "2.0"
// I've defined a custom model here, because the default paginated train
// doesn't allow to use inputToken or outputToken as Integer. It must always be string.
// But in my json response I want to have that metadata as integers, it's just easier to
// later parse it in code and do something like if totalpages == page; exit().
// And so this trait is only used at the operation level, whereas the original
// `paginated` is set at the service level (because that one is responsible for the URL
// query parameters and they are always strings)

namespace custom.api

@private
@length(min: 1)
string NotEmptyString

@trait(
    selector: ":is(service, operation)"
    breakingChanges: [
        {change: "remove"}
        {path: "/inputToken", change: "update"}
        {path: "/outputToken", change: "update"}
        {path: "/items", change: "remove"}
        {path: "/items", change: "add", severity: "NOTE"}
        {path: "/items", change: "update", severity: "NOTE"}
        {path: "/pageSize", change: "update"}
        {path: "/pageSize", change: "remove"}
    ]
)
structure paginatedd {
    /// The name of the operation input member that represents the continuation
    /// token.
    ///
    /// When this value is provided as operation input, the service returns
    /// results from where the previous response left off. This input member
    /// MUST NOT be required and MUST target a string shape.
    inputToken: Integer

    /// The name of the operation output member that represents the
    /// continuation token.
    ///
    /// When this value is present in operation output, it indicates that there
    /// are more results to retrieve. To get the next page of results, the
    /// client uses the output token as the input token of the next request.
    /// This output member MUST NOT be required and MUST target a string shape.
    outputToken: Integer

    /// The name of a top-level output member of the operation that is the data
    /// that is being paginated across many responses.
    ///
    /// The named output member, if specified, MUST target a list or map.
    items: NotEmptyString

    /// The name of an operation input member that limits the maximum number of
    /// results to include in the operation output. This input member MUST NOT
    /// be required and MUST target an integer shape.
    pageSize: NotEmptyString
}
