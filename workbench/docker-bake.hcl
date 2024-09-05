variable image_name {
  default = "workbench"
}

function get_safe_version {
  params = [version]
  result = replace(version, "+", "-")
}

function get_clean_version {
    params = [version]
    result = regex_replace(version, "[+|-].*", "")
}

function get_suffix {
  params = [type]
  result = type == "std" ? "" : "-${type}"
}

function get_tags {
  params = [version, os, type, mark_latest]
  result = concat(
    [
      "${registry}/${namespace}/${image_name}:${os}-${get_clean_version(version)}",
      "${registry}/${namespace}/${image_name}:${os}-${get_clean_version(version)}${get_suffix(type)}",
      "${registry}/${namespace}/${image_name}:${os}-${get_safe_version(version)}",
      "${registry}/${namespace}/${image_name}:${os}-${get_safe_version(version)}${get_suffix(type)}",
    ],
      mark_latest ? ["${registry}/${namespace}/${image_name}:latest${get_suffix(type)}", "${registry}/${namespace}/${image_name}:${os}${get_suffix(type)}"] :
      []
  )
}

variable workbench_build_matrix {
  default = {
    builds = [
      {version = "2024.04.2+764.pro1", os = "ubuntu2204", mark_latest = true},
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
  matrix = workbench_build_matrix
  name = "${builds.os}-${replace(get_clean_version(builds.version), ".", "-")}-std"
  tags = get_tags(builds.version, builds.os, "std", builds.mark_latest)
  dockerfile = "workbench/${builds.version}/Containerfile.${builds.os}.std"
  args = {
    "REGISTRY" = registry
  }
}

target "min" {
  inherits = ["_"]
  matrix = workbench_build_matrix
  name = "${builds.os}-${replace(get_clean_version(builds.version), ".", "-")}-min"
  tags = get_tags(builds.version, builds.os, "min", builds.mark_latest)
  dockerfile = "workbench/${builds.version}/Containerfile.${builds.os}.min"
  args = {
    "REGISTRY" = registry
  }
}
