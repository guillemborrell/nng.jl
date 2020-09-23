using nng
using Test

function test_push_pull()
    push_s = nng.listen("ipc:///tmp/pipeline.ipc", "PUSH0")
    pull_s = nng.dial("ipc:///tmp/pipeline.ipc", "PULL0")

    nng.send(push_s, "Something")
    result = nng.recv(pull_s)

    nng.close(push_s)
    nng.close(pull_s)
    return result
end

@testset "nng.jl" begin
    @test test_push_pull() == "Something"
end
