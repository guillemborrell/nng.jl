module nng

# Write your package code here.
const LIB ="libnng.so"

mutable struct nng_socket
    id::UInt32
end

mutable struct nng_listener
    id::UInt32
end

mutable struct nng_dialer
    id::UInt32
end

mutable struct nng_aio end

const NNG_OPT_SUB_SUBSCRIBE = "sub:subscribe"
const NNG_OPT_SUB_UNSUBSCRIBE = "sub:unsubscribe"

ERROR_CODES = Dict(
1  => "NNG_EINTR",
2  => "NNG_ENOMEM",
3  => "NNG_EINVAL",
4  => "NNG_EBUSY",
5  => "NNG_ETIMEDOUT",
6  => "NNG_ECONNREFUSED",
7  => "NNG_ECLOSED",
8  => "NNG_EAGAIN",
9  => "NNG_ENOTSUP",
10 => "NNG_EADDRINUSE",
11 => "NNG_ESTATE",
12 => "NNG_ENOENT",
13 => "NNG_EPROTO",
14 => "NNG_EUNREACHABLE",
15 => "NNG_EADDRINVAL",
16 => "NNG_EPERM",
17 => "NNG_EMSGSIZE",
18 => "NNG_ECONNABORTED",
19 => "NNG_ECONNRESET",
20 => "NNG_ECANCELED",
21 => "NNG_ENOFILES",
22 => "NNG_ENOSPC",
23 => "NNG_EEXIST",
24 => "NNG_EREADONLY",
25 => "NNG_EWRITEONLY",
26 => "NNG_ECRYPTO",
27 => "NNG_EPEERAUTH",
28 => "NNG_ENOARG",
29 => "NNG_EAMBIGUOUS",
30 => "NNG_EBADTYPE",
31 => "NNG_ECONNSHUT",
1000 => "NNG_EINTERNAL"
)

@enum SOCKET_TYPES begin
    PUSH0
    PULL0
    PUB0
    SUB0
    PAIR0
    REQ0
    REP0
    SURVEYOR0
    RESPONDENT0
end

function _handle_err(err:: Int32)::Int32
    if err != 0
        throw(error("NNG error: $(ERROR_CODES[err])"))
    end
    return err
end

"""
Low level function to get the socket ID.

In many occasions, this returns -1 (Error), but the socket works anyway
"""
_nng_socket_id(socket::nng_socket) =
    ccall((:nng_socket_id, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level function to set a string as an option
"""
_nng_setopt(socket::nng_socket, option::String, value::String) =
    ccall((:nng_setopt, LIB), Cint, (nng_socket, Cstring, Cstring, Csize_t), socket, option, value, length(value))

"""
Low level listen
"""
_nng_listen(socket::nng_socket, url::String) = ccall(
    (:nng_listen, LIB),
    Cint,
    (nng_socket, Cstring, Ref{nng_listener}, Cint),
    socket,
    url,
    Ref(nng_listener(0)),
    0,
)
"""
Low level dial
"""
_nng_dial(socket::nng_socket, url::String) = ccall(
    (:nng_dial, LIB),
    Cint,
    (nng_socket, Cstring, Ref{nng_dialer}, Cint),
    socket,
    url,
    Ref(nng_dialer(0)),
    0,
)

"""
Low level PULL
"""
_nng_pull0_open(socket::nng_socket) =
    ccall((:nng_pull0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level PUSH
"""
_nng_push0_open(socket::nng_socket) =
    ccall((:nng_push0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level PUB
"""
_nng_pub0_open(socket::nng_socket) =
    ccall((:nng_pub0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level SUB
"""
_nng_sub0_open(socket::nng_socket) =
    ccall((:nng_sub0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level PAIR
"""
_nng_pair0_open(socket::nng_socket) = 
    ccall((:nng_pair0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level REQ
"""
_nng_req0_open(socket::nng_socket) = 
ccall((:nng_req0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level REP
"""
_nng_rep0_open(socket::nng_socket) =
ccall((:nng_rep0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level SURVEYOR
"""
_nng_surveyor0_open(socket::nng_socket) =
ccall((:nng_surveyor0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level RESPONDENT
"""
_nng_respondent0_open(socket::nng_socket) =
ccall((:nng_respondent0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))


"""
Low level CLOSE
"""
_nng_close(socket::nng_socket) = ccall((:nng_close, LIB), Cint, (nng_socket,), socket)

"""
Low level SEND.
"""
function _nng_send(socket::nng_socket, message::AbstractString)
    return ccall(
        (:nng_send, LIB),
        Cint,
        (nng_socket, Ptr{UInt8}, Csize_t, Cint),
        socket,
        pointer(message),
        sizeof(message) + 1,
        0,
    )
end

"""
Low level RECV.
"""
function _nng_recv(socket::nng_socket)
    buf = Vector{Ptr{UInt8}}(undef, 1)
    size = Csize_t(0)
    rval = ccall(
        (:nng_recv, LIB),
        Cint,
        (nng_socket, Ptr{UInt8}, Ref{Csize_t}, Cint),
        socket,
        pointer(buf),
        size,
        1,
    )

    msg = unsafe_string(buf[1])
    ccall((:nng_free, LIB), Cvoid, (Ptr{Cvoid}, Csize_t), buf[1], sizeof(msg))

    return msg
end

function_mapping = Dict{SOCKET_TYPES, Function}(
PULL0 => _nng_pull0_open,
PUSH0 => _nng_push0_open,
PUB0 => _nng_pub0_open,
SUB0 => _nng_sub0_open,
PAIR0 => _nng_pair0_open,
REQ0 => _nng_req0_open,
REP0 => _nng_rep0_open,
SURVEYOR0 => _nng_surveyor0_open,
RESPONDENT0 => _nng_respondent0_open
)


"""
NNG listen to a socket for other connections
"""
function listen(addr::String, proto::SOCKET_TYPES)::nng_socket
    if haskey(function_mapping, proto) == false
        throw(error("Not one of accepted socket types"))
    end
    socket = nng_socket(0)
    err_val = _handle_err(function_mapping[proto](socket))
    err_val = _handle_err(_nng_listen(socket, addr))
    return socket
end


"""
NNG dial to a socket
"""
function dial(addr::String, proto::SOCKET_TYPES)::nng_socket
    if haskey(function_mapping, proto) == false
        throw(error("Not one of accepted socket types"))
    end
    socket = nng_socket(0)
    err_val = _handle_err(function_mapping[proto](socket))
    err_val = _handle_err(_nng_dial(socket, addr))
    return socket
end


"""
NNG dial to a socket and subscribe to a topic
"""
function dial(addr::String, proto::SOCKET_TYPES, topic::String)::nng_socket
    if haskey(function_mapping, proto) == false
        throw(error("Not one of accepted socket types"))
    end
    socket = nng_socket(0)
    err_val = _handle_err(function_mapping[proto](socket))
    err_val = _handle_err(_nng_setopt(socket, NNG_OPT_SUB_SUBSCRIBE, topic))
    err_val = _handle_err(_nng_dial(socket, addr))
    return socket
end

"""
NNG close a socket
"""
function close(socket::nng_socket)::Int32
    return _handle_err(_nng_close(socket))
end

"""
NNG subscribe to a topic
"""
function subscribe(socket::nng_socket, topic::String)::Int32
    return _handle_err(_nng_setopt(socket, NNG_OPT_SUB_SUBSCRIBE, topic))
end

"""
NNG unsubscribe to a topic
"""
function unsubscribe(socket::nng_socket, topic::String)::Int32
    return _handle_err(_nng_setopt(socket, NNG_OPT_SUB_UNSUBSCRIBE, topic))
end

"""
NNG send an abstract string from a socket
"""
function send(socket::nng_socket, msg::AbstractString)::Int32
    return _handle_err(_nng_send(socket, msg))
end


"""
NNG receive an abstract string to a socket
"""
function recv(socket::nng_socket)::AbstractString
    return _nng_recv(socket)
end

end
