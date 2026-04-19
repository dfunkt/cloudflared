package docker

default allow := false

allow if {
  input.git.host == "github.com"
  input.git.remote == "https://github.com/dfunkt/cloudflared.git"
}

allow if {
    input.image.hasProvenance
}

decision := {"allow": allow}
