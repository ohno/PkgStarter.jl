module PkgStarter

# Packages

import HTTP
import JSON3
import GitHub
import Sodium
import Base64
import URIs
import DocStringExtensions
import PkgTemplates
import Mustache
import UUIDs
import Dates
# import Oxygen

# Variables

const GITHUB_OAUTH_CLIENT_ID = "Ov23libqpCkC6Z5pSlFG"
const GITHUB_OAUTH_CLIENT_SECRET = "" # Device Flow

function hello()
    return "Hello, World!"
end

# Authorization

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function check_status_code()::Bool
    response = HTTP.get(
        "https://api.github.com/meta";
        retry = true,
        status_exception = false,
        headers = ["User-Agent" => "PkgStarter.jl"],
    )
    return response.status == 200
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function device_flow_begin(client_id::String)::JSON3.Object
    try
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
    catch e
        # @error "device_flow_begin: $(e)"
        return JSON3.read(JSON3.write((
            device_code      = "",
            user_code        = "",
            verification_uri = "",
            expires_in       = 0,
            interval         = 0,
        )))
    end
end

# function device_flow_end(client_id::String, client_secret::String, device_code::String)
"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function device_flow_end(client_id::String, device_code::String)
    try
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
    catch e
        # @error "device_flow_end: $(e)"
        return JSON3.read(JSON3.write((
            access_token             = "",
            expires_in               = 0,
            refresh_token            = "",
            refresh_token_expires_in = 0,
            token_type               = "",
            scope                    = "",
        )))
    end
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function get_user_domain(access_token::String)
    auth = GitHub.authenticate(access_token)
    owner = GitHub.whoami(; auth=auth)
    orgs = GitHub.orgs(owner, auth=auth)
    return [owner.login, [org.login for org in orgs[1]]...]
end

# Repository

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function check_repo(access_token::String, owner_name::String, repo_name::String)
    try
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
    catch e
        return false
    end
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function create_repo(access_token::String, owner_name::String, repo_name::String, package_description::String)
    owner = GitHub.owner(owner_name)
    if owner.typ == "User"
        url = "https://api.github.com/user/repos"
    elseif owner.typ == "Organization"
        url = "https://api.github.com/orgs/$(owner_name)/repos"
    end
    body = JSON3.write(Dict(
        "name" => repo_name,
        "description" => package_description,
        "private" => false,
        "homepage" => "https://$(owner_name).github.io/$(repo_name)",
        "auto_init" => true,
    )) # auto_init = true is required to use commit_files_on_github()
    try
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
        return JSON3.read(String(response.body))
    catch e
        # error("Failed to create repository: $(response.status) - $(String(response.body))")
        return JSON3.read(JSON3.write((
            name = "",
            full_name = "",
            description = "",
        )))
    end
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function create_branch_gh_pages(access_token::String, owner_name::String, repo_name::String)::Bool
    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)
    try
        sha = GitHub.reference(repo, "heads/main"; auth=auth).object["sha"]
        response = GitHub.create_reference(repo; auth=auth, params=Dict("ref" => "refs/heads/gh-pages", "sha" => sha))
        return true
    catch e
        return false
    end
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function set_repository_secret(access_token::String, owner_name::String, repo_name::String, secret_name::String, secret_value::String)

    # https://github.com/JuliaWeb/GitHub.jl?tab=readme-ov-file#ssh-keys
    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)

    # get public key & encrypt
    gpk = GitHub.publickey(GitHub.DEFAULT_API, repo; auth=auth) # equal to GitHub.gh_get_json(GitHub.DEFAULT_API, "/repos/$(GitHub.name(repo))/actions/secrets/public-key"; auth=auth)
    encrypted = Sodium.seal(Vector{UInt8}(secret_value), gpk.key) # repair of GitHub.SodiumSeal.seal(base64encode(secret_value), GitHub.SodiumSeal.KeyPair(gpk.key))

    # set secret
    try
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
    catch e
        return false
    end
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function get_codecov_url(owner_name::String, repo_name::String)::String
    return "https://app.codecov.io/gh/$(owner_name)/$(repo_name)"
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function set_codecov(access_token::String, owner_name::String, repo_name::String, codecov_token::String)
    return set_repository_secret(access_token, owner_name, repo_name, "CODECOV_TOKEN", codecov_token)
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function set_deploy_key(access_token::String, owner_name::String, repo_name::String)
    # https://github.com/JuliaWeb/GitHub.jl?tab=readme-ov-file#ssh-keys
    pubkey, privkey = GitHub.genkeys()
    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)
    try
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
    catch e
        return false
    end
end

# function genkeys(user_name::String, repo_name::String)
#     return DocumenterTools.genkeys(; user = user_name, repo = repo_name)
# end

# Commit

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function get_file_on_github(access_token::String, owner_name::String, repo_name::String, repo_path::String)
    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)
    file = GitHub.file(repo, repo_path; auth = auth)
    return file
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function check_file_on_github(access_token::String, owner_name::String, repo_name::String, branch_name::String, repo_path::String)
    try
        get_file_on_github(access_token, owner_name, repo_name, repo_path)
        return true
    catch e
        return false
    end
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function commit_file_on_github(access_token::String, owner_name::String, repo_name::String, branch_name::String, commit_message::String, path::String, content::String)

    auth = GitHub.authenticate(access_token)
    repo = GitHub.repo("$(owner_name)/$(repo_name)"; auth = auth)

    file = try
        @info "get_file_on_github: $(path)"
        get_file_on_github(access_token, owner_name, repo_name, path)
    catch
        @info "get_file_on_github: $(path) not found"
        nothing
    end

    if isnothing(file)
        params = Dict(
            "message" => commit_message,
            "content" => Base64.base64encode(content),
            "branch"  => branch_name,
        )
        GitHub.create_file(repo, path; auth = auth, params = params)
        @info "create_file: $(path)"
    else
        params = Dict(
            "message" => commit_message,
            "content" => Base64.base64encode(content),
            "branch"  => branch_name,
            "sha"     => file.sha,
        )
        GitHub.update_file(repo, path; auth = auth, params = params)
        @info "update_file: $(path)"
    end

end

"""
!!! warning
    This function does not work for initial commit.

Signature:

$(DocStringExtensions.TYPEDSIGNATURES)
    
Example:

```julia
access_token = "YOUR_ACCESS_TOKEN"
owner_name = "user"
repo_name = "my-github-repo"
branch_name = "main"
commit_message = "Update hello1.md and hello2.md"
paths_and_contents = Dict(
    "hello1.md" => "Hello, 1",
    "hello2.md" => "Hello, 2",
)

PkgStarter.commit_files_on_github(
    access_token,
    owner_name,
    repo_name,
    branch_name,
    commit_message,
    paths_and_contents,
)
```
"""
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

# Template

"""
Signature:

$(DocStringExtensions.TYPEDSIGNATURES)

Example:

```julia
PkgStarter.update_template("OWNER_NAME", "template", ["AUTHOR1", "AUTHOR2"])
```
"""
function update_template(owner_name::String, repo_name::String, author_names::Vector{String})::Dict{String, String}
    template = PkgTemplates.Template(;
        dir = "$(@__DIR__)/../",
        user = owner_name,
        authors = author_names,
        julia = v"1.11",
        plugins = [
            # https://juliaci.github.io/PkgTemplates.jl/stable/user/#Default-Plugins
            PkgTemplates.ProjectFile(; version = v"0.0.1"),
            PkgTemplates.SrcDir(),
            PkgTemplates.Tests(; project = true),
            PkgTemplates.Readme(),
            PkgTemplates.License(),
            # PkgTemplates.Git(; ignore = ["*/Manifest.toml"]),
            PkgTemplates.GitHubActions(; extra_versions = ["1.11"]),
            PkgTemplates.CompatHelper(),
            PkgTemplates.TagBot(),
            # PkgTemplates.Secret(),
            PkgTemplates.Dependabot(),
            # https://juliaci.github.io/PkgTemplates.jl/stable/user/#Code-Coverage
            PkgTemplates.Codecov(),
            # https://juliaci.github.io/PkgTemplates.jl/stable/user/#Documentation
            PkgTemplates.Documenter{PkgTemplates.GitHubActions}(),
            # https://juliaci.github.io/PkgTemplates.jl/stable/user/#Miscellaneous
            PkgTemplates.Citation(; readme = true),
            # PkgTemplates.Formatter(),
        ],
    )
    return template(repo_name)
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function list_files()
    return [joinpath(dir, f) for (dir, _, fs) in walkdir("$(dirname(@__FILE__()))/../template") for f in fs]
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function load_file(path::String)::String
    try
        file = open(path, "r")
        text = Base.read(file, String)
        close(file)
        return text
    catch
        return ""
    end
end

"""
$(DocStringExtensions.TYPEDSIGNATURES)
"""
function generate_template_dict(owner_name::String, repo_name::String, author_names::Vector{String}, package_description::String)

    ctx = Dict(
        "PKG"      => replace(repo_name, ".jl" => ""),
        "REPO"     => repo_name,
        "OWNER"    => owner_name,
        "DESCR"    => package_description,
        "UUID"     => string(UUIDs.uuid4()),
        "AUTHORS"  => author_names,
        "LICENSOR" => join(author_names, ", "),
        "URL"      => "https://github.com/$(owner_name)/$(repo_name)",
        "VERSION"  => "v0.0.1",
        "YEAR"     => Dates.year(Dates.today()),
        "MONTH"    => Dates.month(Dates.today()),
    )

    paths_and_contents = Dict{String, String}()

    for path in PkgStarter.list_files()
        key = relpath(path, "$(@__DIR__)/../template")
        key = replace(key, "\\" => "/")
        if key == "src/PKG.jl"
            key = "src/$(ctx["PKG"]).jl"
        end
        text = PkgStarter.load_file(path)
        rendered = if key[end-3:end] == ".yml" && key[end-5:end] != "CI.yml"
            text
        else
            Mustache.render(text, ctx)
        end
        paths_and_contents[key] = rendered
    end
    
    return paths_and_contents

end

end
