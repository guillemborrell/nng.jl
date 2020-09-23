include("nng.jl")

socket_1 = nng_socket(0)

# Create the sockets
rval = _nng_push0_open(socket_1)
println("Return value of PUSH socket: ", rval)
println("Socket id for PULL socket: ", _nng_socket_id(socket_1))

# Connect the sockets
rval = _nng_listen(socket_1, "ipc:///tmp/pipeline.ipc")
println("Return value of LISTEN: ", rval)

# Send a message to the world
rval = _nng_send(socket_1, "Testing")
println("Return value of SEND: ", rval)

rval = _nng_close(socket_1)
println("Return value of CLOSE: ", rval)