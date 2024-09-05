variable registry {
  default = "docker.io"
}

variable namespace {
  default = "posit"
}

variable image_name {
  default = "workbench"
}

target "_" {
  labels = {
    "org.opencontainers.image.created" = timestamp()
    "org.opencontainers.image.authors" = "Ian H. Pittwood <ian.pittwood@posit.co>"
    "org.opencontainers.image.source" = "github.com/rstudio/posit-images-base"
    "org.opencontainers.image.vendor" = "Posit Software, PBC"
  }
  context = "."
}
