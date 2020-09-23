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

function test_push_pull_error_reversed()
    push_s = nng.listen("ipc:///tmp/pipeline.ipc", nng.PULL0)
    pull_s = nng.dial("ipc:///tmp/pipeline.ipc", nng.PUSH0)

    nng.send(push_s, "Something")
    result = nng.recv(pull_s)

    nng.close(push_s)
    nng.close(pull_s)
    return result
end


@testset "nng.jl" begin
    @test test_push_pull() == "Something"
    @test_throws ErrorException("NNG error: NNG_ENOTSUP") test_push_pull_error_reversed() == "Something"
end
