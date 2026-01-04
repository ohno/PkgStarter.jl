using HTTP
using JSON3
using GitHub

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