variable registry {
  default = "docker.io"
}

variable namespace {
  default = "posit"
}

variable "GIT_SHA" {
  default = "$GIT_SHA"
}

target "_" {
  labels = {
    "maintainer" = "Posit Docker <docker@posit.co>"
    "org.opencontainers.image.created" = timestamp()
    "org.opencontainers.image.authors" = "Ian H. Pittwood <ian.pittwood@posit.co>"
    "org.opencontainers.image.source" = "github.com/rstudio/proto-posit-images-workbench"
    "org.opencontainers.image.documentation" = "https://docs.posit.co/ide/server-pro/"
    "org.opencontainers.image.revision" = GIT_SHA
    "org.opencontainers.image.vendor" = "Posit Software, PBC"
  }
  context = "."
}
