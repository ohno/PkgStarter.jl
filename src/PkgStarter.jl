module PkgStarter

# Packages

import HTTP
import JSON3
import GitHub
import Sodium
import Base64
import URIs

# Variables

const GITHUB_OAUTH_CLIENT_ID = "Ov23libqpCkC6Z5pSlFG"
const GITHUB_OAUTH_CLIENT_SECRET = "" # Device Flow

function hello()
    return "Hello, World!"
end

# Authorization

function check_status_code()::Bool
    response = HTTP.get(
        "https://api.github.com/meta";
        retry = true,
        status_exception = false,
        headers = ["User-Agent" => "PkgStarter.jl"],
    )
    return response.status == 200
end

function device_flow_begin(client_id::String)::JSON3.Object
    response = HTTP.post(
        "https://github.com/login/device/code";
        headers = [
            "Accept" => "application/json",
            "Content-Type" => "application/x-www-form-urlencoded",
            "User-Agent" => "PkgStarter.jl",
        ],
        body = "client_id=$(client_id)&scope=read:user%20public_repo%20repo",
    )
    return JSON3.read(String(response.body))
end

# function device_flow_end(client_id::String, client_secret::String, device_code::String)
function device_flow_end(client_id::String, device_code::String)
    response = HTTP.post(
        "https://github.com/login/oauth/access_token";
        headers = [
            "Accept" => "application/json",
            "Content-Type" => "application/x-www-form-urlencoded",
            "User-Agent" => "PkgStarter.jl",
        ],
        # body = "client_id=$(client_id)&device_code=$(device_code)&grant_type=urn:ietf:params:oauth:grant-type:device_code&client_secret=$(client_secret)"
        body = "client_id=$(client_id)&device_code=$(device_code)&grant_type=urn:ietf:params:oauth:grant-type:device_code",
    )
    return JSON3.read(String(response.body))
end

function get_user_info(access_token::String)
    # response = HTTP.get(
    #   "https://api.github.com/user";
    #   headers = [
    #     "Accept" => "application/vnd.github+json",
    #     "Authorization" => "Bearer $(access_token)",
    #     "X-GitHub-Api-Version" => "2022-11-28",
    #     "User-Agent" => "PkgStarter.jl"
    #   ],
    # )
    # return JSON3.read(String(response.body))
    auth = GitHub.authenticate(access_token)
    api = isdefined(GitHub, :DEFAULT_API) ? GitHub.DEFAULT_API : GitHub.GitHubWebAPI(URIs.URI("https://api.github.com"))
    return GitHub.gh_get(api, "/user"; auth = auth)
end

# Repository

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

# Commit

function get_file_on_github(access_token::String, owner_name::String, repo_name::String, repo_path::String)
    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)
    file = GitHub.file(repo, repo_path; auth = auth)
    return file
end

function check_file_on_github(access_token::String, owner_name::String, repo_name::String, branch_name::String, repo_path::String)
    try
        get_file_on_github(access_token, owner_name, repo_name, repo_path)
        return true
    catch e
        return false
    end
end

function commit_file_on_github(access_token::String, owner_name::String, repo_name::String, branch_name::String, commit_message::String, path::String, content::String)

    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)

    file = try 
        get_file_on_github(access_token, owner_name, repo_name, path)
    catch
        nothing
    end

    if isnothing(file)
        params = Dict(
            "message" => commit_message,
            "content" => Base64.base64encode(content),
            "branch"  => branch_name,
        )
        GitHub.create_file(repo, path; auth = auth, params = params)
    else
        params = Dict(
            "message" => commit_message,
            "content" => Base64.base64encode(content),
            "branch"  => branch_name,
            "sha"     => file.sha,
        )
        GitHub.update_file(repo, path; auth = auth, params = params)
    end

end

function commit_files_on_github(
    access_token::String,
    owner_name::String,
    repo_name::String,
    branch_name::String,
    commit_message::String,
    paths_and_contents::Dict{String, String},
)
    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)

    ref_name = "heads/$branch_name"
    current_ref = GitHub.reference(repo, ref_name; auth=auth)
    latest_commit_sha = current_ref.object["sha"]
    latest_commit = GitHub.commit(repo, latest_commit_sha; auth=auth)
    base_tree_sha = latest_commit.sha
    tree_entries = []
    for (path, content) in paths_and_contents
        push!(tree_entries, Dict(
            "path" => path,
            "mode" => "100644",
            "type" => "blob",
            "content" => content
        ))
    end

    new_tree = GitHub.create_tree(repo; auth = auth, params = Dict(
        "tree" => tree_entries,
        "base_tree" => base_tree_sha,
    ))

    new_commit = GitHub.create_gitcommit(repo; auth = auth, params = Dict(
        "message" => commit_message,
        "tree" => new_tree.sha,
        "parents" => [latest_commit_sha],
    ))

    GitHub.update_reference(repo, current_ref; auth = auth, params = Dict(
        "ref" => ref_name,
        "sha" => new_commit.sha,
    ))
end

end
