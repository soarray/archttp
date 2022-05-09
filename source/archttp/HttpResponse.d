/*
 * Archttp - A highly performant web framework written in D.
 *
 * Copyright (C) 2021-2022 Kerisy.com
 *
 * Website: https://www.kerisy.com
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module archttp.HttpResponse;

import archttp.HttpStatusCode;
import archttp.HttpContext;

import std.format;
import std.array;
import std.conv : to;

class HttpResponse
{
    alias string[string]   headerList;

    ushort       _status = HttpStatusCode.OK;
    headerList   _headers;
    string       _body;
    string       _buffer;
    HttpContext  _httpContext;

public:
    /*
     * Construct an empty response.
     */
    this(HttpContext ctx)
    {
        _httpContext = ctx;
    }

    /*
     * Sets a header field.
     *
     * Setting the same header twice will overwrite the previous, and header keys are case
     * insensitive. When sent to the client the header key will be as written here.
     *
     * @param header the header key
     * @param value the header value
     */
    HttpResponse header(string header, string value)
    {
        _headers[header] = value;
        
        return this;
    }

    /*
     * Set the HTTP status of the response.
     *
     * @param status_code the status code
     */
    HttpResponse status(HttpStatusCode status_code)
    {
        _status = status_code;

        return this;
    }

    /*
     * Set the entire body of the response.
     *
     * Sets the body of the response, overwriting any previous data stored in the body.
     *
     * @param body the response body
     */
    HttpResponse body(string body)
    {
        _body = body;
        return this;
    }

    /*
     * Get the status of the response.
     *
     * @return the status of the response
     */
    ushort status()
    {
        return _status;
    }

    //  -----  serializer  -----

    /*
     * Generate an HTTP response from this object.
     *
     * Uses the configured parameters to generate a full HTTP response and returns it as a
     * string.
     *
     * @return the HTTP response
     */
    ubyte[] ToBuffer()
    {
        header("Content-Length", _body.length.to!string);

        auto app = appender!string;
        app ~= format!"HTTP/1.1 %d %s\r\n"(_status, getHttpStatusMessage(_status));
        foreach (name, value; _headers) {
            app ~= format!"%s: %s\r\n"(name, value);
        }
        app ~= "\r\n";

        app ~= _body.dup;
        
        return cast(ubyte[]) app[];
    }
}
