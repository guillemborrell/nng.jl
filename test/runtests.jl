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
    sleep(1)

    nng.send(pub_s, "Something")
    result = nng.recv(sub_s)

    nng.close(pub_s)
    nng.close(sub_s)
    return result
end

function test_pair()
    pair_1 = nng.listen("ipc:///tmp/pair.ipc", nng.PAIR0)
    pair_2 = nng.dial("ipc:///tmp/pair.ipc", nng.PAIR0)
    sleep(1)

    nng.send(pair_1, "One way")
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

function test_surveyor_respondent()
    surv = nng.listen("ipc:///tmp/survey.ipc", nng.SURVEYOR0)
    resp = nng.dial("ipc:///tmp/survey.ipc", nng.RESPONDENT0)
    sleep(1)

    nng.send(surv, "One way")
    message = nng.recv(resp)
    
    nng.send(resp, "The other way")
    message = nng.recv(surv)

    nng.close(surv)
    nng.close(resp)

    return message
end


@testset "nng.jl" begin
    @test test_push_pull() == "Something"
    @test test_pub_sub() == "Something"
    @test test_pair() == "One way"
    @test test_req_rep() == "The other way"
    @test test_surveyor_respondent() == "The other way"
end
