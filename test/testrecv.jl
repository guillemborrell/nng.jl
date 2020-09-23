include("nng.jl")

socket_1 = nng_socket(0)

# Create the sockets
rval = _nng_pull0_open(socket_1)
println("Return value of PULL socket: ", rval)
println("Socket id for PULL socket: ", _nng_socket_id(socket_1))

# Connect the sockets
rval = _nng_dial(socket_1, "ipc:///tmp/pipeline.ipc")
println("Return value of DIAL: ", rval)

# Send a message to the world
rval = _nng_recv(socket_1)
println("Return value of RECV: ", rval)

rval = _nng_close(socket_1)
println("Return value of CLOSE: ", rval)