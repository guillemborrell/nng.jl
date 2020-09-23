using nng
using Test

function test_push_pull()
    push_s = nng.listen("ipc:///tmp/pipeline.ipc", nng.PUSH0)
    pull_s = nng.dial("ipc:///tmp/pipeline.ipc", nng.PULL0)

    nng.send(push_s, "Something")
    result = nng.recv(pull_s)

    nng.close(push_s)
    nng.close(pull_s)
    return result
end

function test_pub_sub()
    pub_s = nng.listen("ipc:///tmp/pub.ipc", nng.PUB0)
    sub_s = nng.dial("ipc:///tmp/pub.ipc", nng.SUB0, "") # Subscribe to all topics

    nng.send(pub_s, "Something")
    sleep(0.2)  #Enough time for the sub socket to start
    result = nng.recv(sub_s)

    nng.close(pub_s)
    nng.close(sub_s)
    return result
end

function test_pair()
    pair_1 = nng.listen("ipc:///tmp/pair.ipc", nng.PAIR0)
    pair_2 = nng.dial("ipc:///tmp/pair.ipc", nng.PAIR0)

    nng.send(pair_1, "One way")
    sleep(0.2)
    result = nng.recv(pair_2)

    nng.close(pair_1)
    nng.close(pair_2)
    
    return result
end

function test_req_rep()
    rep = nng.listen("ipc:///tmp/reqrep.ipc", nng.REP0)
    req = nng.dial("ipc:///tmp/reqrep.ipc", nng.REQ0)

    nng.send(req, "One way")
    message = nng.recv(rep)

    nng.send(rep, "The other way")
    message = nng.recv(req)

    nng.close(rep)
    nng.close(req)

    return message
end

@testset "nng.jl" begin
    @test test_push_pull() == "Something"
    @test test_pub_sub() == "Something"
    @test test_pair() == "One way"
    @test test_req_rep() == "The other way"
end
