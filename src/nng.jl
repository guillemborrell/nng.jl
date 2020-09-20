module nng

# Write your package code here.
const LIB = "libnng.so"

mutable struct nng_socket
    id::UInt32
end

mutable struct nng_listener
    id::UInt32
end

mutable struct nng_dialer
    id::UInt32
end

"""
Low level function to get the socket ID.

In many occasions, this returns -1 (Error), but the socket works anyway
"""
_nng_socket_id(socket::nng_socket) =
    ccall((:nng_socket_id, LIB), Cint, (Ref{nng_socket},), Ref(socket))

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
    ccall((:nng_psub0_open, LIB), Cint, (Ref{nng_socket},), Ref(socket))

"""
Low level CLOSE
"""
_nng_close(socket::nng_socket) = ccall((:nng_close, LIB), Cint, (nng_socket,), socket)

"""
Low level SEND. At this point only sync operation supported
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
Low level RECV. At this point only sync operation supported
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

end
