# Homebrew formula for PortX.
#
# Recommended install (short name after tap):
#   brew tap jordanliu/portx
#   brew install portx
#
# One-liner (auto-taps):
#   brew install jordanliu/portx/portx
#
# curl installer:
#   curl -fsSL https://raw.githubusercontent.com/jordanliu/portx/main/scripts/install.sh | bash
#
# cloudflared is a required runtime dependency (not bundled).
class Portx < Formula
  desc "Temporary public development URLs via Cloudflare Tunnel"
  homepage "https://github.com/jordanliu/portx"
  # PRE-RELEASE PLACEHOLDER: this formula is not installable until the first
  # real release. CI must replace both fields from the tagged archive; never
  # replace the SHA with an invented value.
  url "https://github.com/jordanliu/portx/releases/download/v0.1.0/portx-0.1.0.tar.gz"
  sha256 "29f2377a998a94872beaf24a620668e03ca21c3ccac38f3416f5de939bfe833a"
  license "MIT"
  head "https://github.com/jordanliu/portx.git", branch: "main"

  depends_on "go" => :build
  depends_on "cloudflared"

  def install
    version_str = if build.head?
      "0.0.0-dev"
    else
      version.to_s
    end
    commit = Utils.git_short_head(length: 7) if build.head? && Utils.git_available?

    ldflags = %W[
      -s -w
      -X portx/internal/buildinfo.Version=#{version_str}
      -X portx/internal/buildinfo.Commit=#{commit || "homebrew"}
      -X portx/internal/buildinfo.Date=#{time.iso8601}
    ]

    ENV["CGO_ENABLED"] = "0"
    # Homebrew's Go formula can lag the minimum version declared by go.mod.
    # Let Go resolve that declared toolchain instead of failing with GOTOOLCHAIN=local.
    ENV["GOTOOLCHAIN"] = "auto"
    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/portx"
  end

  def caveats
    <<~EOS
      PortX is ready. cloudflared was installed as a dependency.

      Quick start (no Cloudflare account):
        portx http 3000

      Custom hostname (one-time setup):
        portx setup
        portx http --url=api.example.dev 3000

      Docs: #{homepage}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/portx version")
    assert_match "http", shell_output("#{bin}/portx http --help")
  end
end
