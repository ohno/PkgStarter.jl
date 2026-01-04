using HTTP
using JSON3
using GitHub
using Sodium
using Base64

function check_repo(access_token::String, owner_name::String, repo_name::String)
    response = HTTP.get(
        "https://api.github.com/repos/$(owner_name)/$(repo_name)";
        headers = [
            "Accept" => "application/vnd.github+json",
            "Authorization" => "Bearer $(access_token)",
            "X-GitHub-Api-Version" => "2022-11-28",
            "User-Agent" => "PkgStarter.jl",
        ],
        status_exception = false,
    )
    return response.status == 200
end

function create_repo(access_token::String, owner_name::String, repo_name::String)
    # def owner
    owner = GitHub.owner(owner_name)
    if owner.typ == "User"
        url = "https://api.github.com/user/repos"
    elseif owner.typ == "Organization"
        url = "https://api.github.com/orgs/$(owner_name)/repos"
    end

    # auth = GitHub.authenticate(access_token)
    # params = Dict(
    #     "description" => "",
    #     "private"     => false,
    #     "auto_init"   => false,
    # )
    # repo = GitHub.create_repo(owner, repo_name; auth=auth, params=params)

    body = JSON3.write(Dict("name" => repo_name, "private" => false, "auto_init" => false))

    response = HTTP.post(
        url;
        headers = [
            "Accept" => "application/vnd.github+json",
            "Authorization" => "Bearer $(access_token)",
            "X-GitHub-Api-Version" => "2022-11-28",
            "User-Agent" => "PkgStarter.jl",
        ],
        body = body,
        status_exception = false,
    )

    if response.status in [200, 201]
        return JSON3.read(String(response.body))
    else
        error("Failed to create repository: $(response.status) - $(String(response.body))")
    end
end

function set_repository_secret(access_token::String, owner_name::String, repo_name::String, secret_name::String, secret_value::String)

    # https://github.com/JuliaWeb/GitHub.jl?tab=readme-ov-file#ssh-keys
    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)

    # get public key & encrypt
    gpk = GitHub.publickey(GitHub.DEFAULT_API, repo; auth=auth) # equal to GitHub.gh_get_json(GitHub.DEFAULT_API, "/repos/$(GitHub.name(repo))/actions/secrets/public-key"; auth=auth)
    encrypted = Sodium.seal(Vector{UInt8}(secret_value), gpk.key) # repair of GitHub.SodiumSeal.seal(base64encode(secret_value), GitHub.SodiumSeal.KeyPair(gpk.key))

    # set secret
    response = GitHub.gh_put(
        GitHub.DEFAULT_API,
        "/repos/$(owner_name)/$(repo_name)/actions/secrets/$(secret_name)";
        handle_error = false,
        params = Dict(
            "encrypted_value" => encrypted,
            "key_id" => gpk.key_id,
        ),
        auth = auth,
    )

    return response.status in [201, 204]
end

function get_codecov_url(owner_name::String, repo_name::String)::String
    return "https://app.codecov.io/gh/$(owner_name)/$(repo_name)"
end

function set_codecov(access_token::String, owner_name::String, repo_name::String, codecov_token::String)
    return set_repository_secret(access_token, owner_name, repo_name, "CODECOV_TOKEN", codecov_token)
end

function set_deploy_key(access_token::String, owner_name::String, repo_name::String)
    # https://github.com/JuliaWeb/GitHub.jl?tab=readme-ov-file#ssh-keys
    pubkey, privkey = GitHub.genkeys()
    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)
    response1 = GitHub.create_deploykey(
        repo;
        auth = auth,
        params = Dict(
            "key" => pubkey,
            "title" => "Documenter",
            "read_only" => false,
            "handle_error" => false,
        ),
    )
    response2 = PkgStarter.set_repository_secret(access_token, owner_name, repo_name, "DEPLOY_KEY", privkey)
    if !isnothing(response1.id) && response2
        return true
    else
        return false
    end
end