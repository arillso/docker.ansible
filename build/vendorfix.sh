#!/bin/sh
# Replace a package pip vendors with a fixed release.
#
# Used for:
# - msgpack, GHSA-6v7p-g79w-8964: the affected Unpacker lives in
#   pip/_vendor/msgpack/fallback.py, and every pip release up to 26.2.1 vendors
#   the same 1.1.2.
# - urllib3, CVE-2026-97687 and CVE-2026-97689: pip 26.2.2 vendors 2.7.0. pip's
#   vendoring patches to urllib3 only touch docstrings, the emscripten backend
#   and optional brotli support, none of which pip relies on here.
#
# Vendored packages are not venv packages, so requirements.txt cannot reach
# them, and bumping pip does not help while upstream still bundles the old copy.
#
# vendor.txt and bom.cdx.json are pip's own record of what it bundles. Both are
# rewritten so neither a human nor a scanner still reads the old version; Trivy
# takes the version from the SBOM, whose findings carry a BOMRef and no file
# path. Nothing in pip reads either file at runtime.
#
# The setuptools findings Trivy reports against this tree (CVE-2025-47273,
# CVE-2026-59890) come from a stale SBOM credit, not from vendored code that
# contains the bug — see .trivyignore.
set -eu

venv="${1:?usage: vendorfix.sh <venv-dir> <package> <requirement>}"
pkg="${2:?usage: vendorfix.sh <venv-dir> <package> <requirement>}"
req="${3:?usage: vendorfix.sh <venv-dir> <package> <requirement>}"

vendor_dir="$(echo "$venv"/lib/python*/site-packages/pip/_vendor)"
[ -d "$vendor_dir" ] || {
    echo "vendorfix: no pip/_vendor under $venv" >&2
    exit 1
}

stage=/tmp/vendorfix
"$venv/bin/pip" install --no-cache-dir --no-deps --target "$stage" "$req"
[ -d "$stage/$pkg" ] || {
    echo "vendorfix: pip install produced no $pkg" >&2
    exit 1
}

version="$(sed -n 's/^Version: //p;T;q' "$stage/$pkg"-*.dist-info/METADATA)"
[ -n "$version" ] || {
    echo "vendorfix: no Version in $pkg METADATA" >&2
    exit 1
}

rm -rf "${vendor_dir:?}/$pkg"
cp -a "$stage/$pkg" "$vendor_dir/$pkg"

# pip's resolver imports both on every run; fail the build, not the user's first
# `pip install`, if the swap left the tree unimportable.
"$venv/bin/python" -c "from pip._vendor import msgpack, pkg_resources; import pip._internal.network.session"

sed -i "s/^\([[:space:]]*\)$pkg==.*/\1$pkg==$version/" "$vendor_dir/vendor.txt"
grep -q "$pkg==$version" "$vendor_dir/vendor.txt"

"$venv/bin/python" - "$vendor_dir/bom.cdx.json" "$pkg" "$version" <<'PY'
import json
import sys

path, name, version = sys.argv[1:4]
bom = json.load(open(path))

patched = 0
for component in bom.get("components", []):
    if component.get("name") != name:
        continue
    component["version"] = version
    for key in ("purl", "bom-ref"):
        if key in component:
            component[key] = f"pkg:pypi/{name}@{version}"
    patched += 1

if not patched:
    sys.exit(f"vendorfix: no {name} component in SBOM")

json.dump(bom, open(path, "w"), indent=2)
PY

rm -rf "$stage"
