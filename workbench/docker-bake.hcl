variable os {
  default = "ubuntu"
}

function get_safe_version {
  params = [version]
  result = replace(version, ".", "")
}

function get_suffix {
  params = [type]
  result = type == "std" ? "" : "-${type}"
}

function get_tag {
  params = [version, type]
  result = "ubuntu${get_safe_version(version)}${get_suffix(type)}"
}

variable ubuntu_build_matrix {
  default = {
    versions = [
      "22.04"
    ]
  }
}

group "default" {
  targets = [
    "std",
    "min"
  ]
}

target "std" {
  inherits = ["_"]
  matrix = ubuntu_build_matrix
  name = "${get_tag(versions, "std")}"
  tags = [
    "${namespace}/${image_name}:${get_tag(versions, "std")}"
  ]
  dockerfile = "${os}/${versions}/Containerfile.std"
}

target "min" {
  inherits = ["_"]
  matrix = ubuntu_build_matrix
  name = "${get_tag(versions, "min")}"
  tags = [
    "${namespace}/${image_name}:${get_tag(versions, "min")}"
  ]
  dockerfile = "${os}/${versions}/Containerfile.min"
}
