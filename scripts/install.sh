#!/usr/bin/env bash

set -euo pipefail

version_input="${INPUT_VERSION:-latest}"
repository="${INPUT_REPOSITORY:-leszko11/google-play-console-cli}"
api_url="https://api.github.com/repos/${repository}/releases/latest"

auth_header=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_header=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

if [[ -z "${version_input}" || "${version_input}" == "latest" ]]; then
  release_json="$(curl -fsSL "${auth_header[@]}" -H "Accept: application/vnd.github+json" "${api_url}")"
  resolved_version="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])' <<<"${release_json}")"
else
  resolved_version="${version_input}"
  if [[ "${resolved_version}" != v* ]]; then
    resolved_version="v${resolved_version}"
  fi
fi

uname_s="$(uname -s)"
case "${uname_s}" in
  Linux) os="linux" ;;
  Darwin) os="darwin" ;;
  MINGW*|MSYS*|CYGWIN*) os="windows" ;;
  *)
    echo "Unsupported operating system: ${uname_s}" >&2
    exit 1
    ;;
esac

uname_m="$(uname -m)"
case "${uname_m}" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *)
    echo "Unsupported architecture: ${uname_m}" >&2
    exit 1
    ;;
esac

asset_ext="tar.gz"
if [[ "${os}" == "windows" ]]; then
  asset_ext="zip"
fi

asset_name="gpc_${resolved_version}_${os}_${arch}.${asset_ext}"
download_url="https://github.com/${repository}/releases/download/${resolved_version}/${asset_name}"
install_root="${RUNNER_TEMP:-/tmp}/setup-gpc/${resolved_version}/${os}-${arch}"
archive_path="${install_root}/${asset_name}"
binary_name="gpc"
if [[ "${os}" == "windows" ]]; then
  binary_name="gpc.exe"
fi

mkdir -p "${install_root}"
curl -fsSL "${download_url}" -o "${archive_path}"

if [[ "${asset_ext}" == "zip" ]]; then
  unzip -q -o "${archive_path}" -d "${install_root}"
else
  tar -xzf "${archive_path}" -C "${install_root}"
fi

binary_path="$(find "${install_root}" -type f -name "${binary_name}" | head -n 1)"
if [[ -z "${binary_path}" ]]; then
  echo "Downloaded archive did not contain ${binary_name}" >&2
  exit 1
fi

chmod +x "${binary_path}"
dirname "${binary_path}" >>"${GITHUB_PATH}"
{
  echo "version=${resolved_version}"
  echo "binary-path=${binary_path}"
} >>"${GITHUB_OUTPUT}"
