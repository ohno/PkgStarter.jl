module PkgStarter

const GITHUB_OAUTH_CLIENT_ID = "Ov23libqpCkC6Z5pSlFG"
const GITHUB_OAUTH_CLIENT_SECRET = "" # Device Flow

function hello()
    return "Hello, World!"
end

include("auth.jl")
include("repo.jl")

end
