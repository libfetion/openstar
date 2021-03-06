
local headers = ngx.req.get_headers()
local method = ngx.var.request_method
local args = ngx.req.get_uri_args() or {}
local url = ngx.unescape_uri(ngx.var.uri)
local request_url = ngx.unescape_uri(ngx.var.request_uri)
local lua_version


local config_dict = ngx.shared.config_dict

local cjson_safe = require "cjson.safe"
local config_base = cjson_safe.decode(config_dict:get("base")) or {}

if jit then 
    lua_version = jit.version
else 
    lua_version = _VERSION
end
local debug_tb = {
    _Openstar_version = config_base.openstar_version,
    _pid = ngx.worker.pid(),
    _worker_count =ngx.worker.count(),
    _worker_id = ngx.worker.id(),
    _ngx_configure=ngx.config.nginx_configure(),
    _ngx_prefix=ngx.config.prefix(),
    _lua_version = lua_version,
    _ngx_lua_version = ngx.config.ngx_lua_version,
    _url = url,
    _method = method,
    _request_url = request_url,
    _args = args,
    _headers = headers,
    _schema = ngx.var.schema,
    _var_host = ngx.var.host,
    _hostname = ngx.var.hostname,
    _servername = ngx.var.server_name or "unknownserver",
    _remoteIp = ngx.var.remote_addr,
    _filename = ngx.var.request_filename,
    _query_string = ngx.unescape_uri(ngx.var.query_string),
    _nowtime=ngx.var.time_local or "time error",
    _remote_addr = ngx.var.remote_addr,
    _remote_port = ngx.var.remote_port,
    _remote_user = ngx.var.remote_user,
    _remote_passwd = ngx.var.remote_passwd,
    _content_type = ngx.var.content_type,
    _content_length = ngx.var.content_length,
    _nowstatus=ngx.var.status or "-",
    _request=ngx.var.request or "-",
    _bodybyte = ngx.var.body_bytes_sent or "-"  
}

if method == "GET" then
    sayHtml_ext(debug_tb)
elseif method == "POST" then
    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    if not data then 
        local datafile = ngx.req.get_body_file()
        if datafile then
            local fh, err = io.open(datafile, "r")
            if fh then
                fh:seek("set")
                local body_data = fh:read("*a")
                fh:close()
                data = body_data
            end
        end
    end
    debug_tb["_PostData"] = data
    sayHtml_ext(debug_tb)
else
    ngx.say("method error")
end