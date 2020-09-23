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
    sleep(1)  #Enough time for the sub socket to start
    result = nng.recv(sub_s)

    nng.close(pub_s)
    nng.close(sub_s)
    return result
end

@testset "nng.jl" begin
    @test test_push_pull() == "Something"
    @test test_pub_sub() == "Something"
end
