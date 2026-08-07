#!/bin/sh
# Replace the msgpack copy pip vendors, for GHSA-6v7p-g79w-8964.
#
# The affected Unpacker lives in pip/_vendor/msgpack/fallback.py, which really is
# in the image. msgpack is not a venv package, so requirements.txt cannot reach
# it, and every pip release up to 26.2.1 vendors the same 1.1.2, so bumping pip
# does not help either.
#
# vendor.txt and bom.cdx.json are pip's own record of what it bundles. Both are
# rewritten so neither a human nor a scanner still reads 1.1.2; Trivy takes the
# version from the SBOM, whose findings carry a BOMRef and no file path. Nothing
# in pip reads either file at runtime.
#
# The other finding Trivy reports against this tree, CVE-2025-47273 against
# setuptools, is a stale SBOM credit rather than code — see .trivyignore.
set -eu

venv="${1:?usage: vendorfix-msgpack.sh <venv-dir>}"

vendor_dir="$(echo "$venv"/lib/python*/site-packages/pip/_vendor)"
[ -d "$vendor_dir" ] || {
    echo "vendorfix: no pip/_vendor under $venv" >&2
    exit 1
}

stage=/tmp/vendorfix
"$venv/bin/pip" install --no-cache-dir --target "$stage" "msgpack>=1.2.1"
[ -d "$stage/msgpack" ] || {
    echo "vendorfix: pip install produced no msgpack" >&2
    exit 1
}

version="$(sed -n 's/^Version: //p;T;q' "$stage"/msgpack-*.dist-info/METADATA)"
[ -n "$version" ] || {
    echo "vendorfix: no Version in msgpack METADATA" >&2
    exit 1
}

rm -rf "${vendor_dir:?}/msgpack"
cp -a "$stage/msgpack" "$vendor_dir/msgpack"

# pip's resolver imports both on every run; fail the build, not the user's first
# `pip install`, if the swap left the tree unimportable.
"$venv/bin/python" -c "from pip._vendor import msgpack, pkg_resources"

sed -i "s/^msgpack==.*/msgpack==$version/" "$vendor_dir/vendor.txt"
grep -q "msgpack==$version" "$vendor_dir/vendor.txt"

"$venv/bin/python" - "$vendor_dir/bom.cdx.json" "$version" <<'PY'
import json
import sys

path, version = sys.argv[1], sys.argv[2]
bom = json.load(open(path))

patched = 0
for component in bom.get("components", []):
    if component.get("name") != "msgpack":
        continue
    component["version"] = version
    for key in ("purl", "bom-ref"):
        if key in component:
            component[key] = "pkg:pypi/msgpack@" + version
    patched += 1

if not patched:
    sys.exit("vendorfix: no msgpack component in SBOM")

json.dump(bom, open(path, "w"), indent=2)
PY

rm -rf "$stage"
