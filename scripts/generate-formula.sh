#!/bin/bash
set -euo pipefail

REPO="shonenada-vibe/night-shift"

# Get version from argument or latest git tag
VERSION="${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo "")}"
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>" >&2
  echo "  e.g. $0 v0.1.0" >&2
  exit 1
fi

# Strip leading 'v' for formula version
FORMULA_VERSION="${VERSION#v}"

URL="https://github.com/${REPO}/archive/refs/tags/${VERSION}.tar.gz"

# echo "Fetching tarball to compute SHA256..." >&2
SHA256=$(curl -sL "$URL" | shasum -a 256 | awk '{print $1}')

if [ "$SHA256" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]; then
  echo "Error: Empty response. Tag '${VERSION}' may not exist." >&2
  exit 1
fi

cat <<EOF
class Nightshift < Formula
  desc "Toggle macOS Night Shift from the menu bar or command line"
  homepage "https://github.com/${REPO}"
  url "${URL}"
  sha256 "${SHA256}"
  license "MIT"
  version "${FORMULA_VERSION}"

  depends_on :macos

  def install
    system "clang", "-framework", "Foundation", "-framework", "Cocoa",
           "-o", "nightshift", "nightshift.m"
    bin.install "nightshift"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/nightshift --help 2>&1", 1)
  end
end
EOF
