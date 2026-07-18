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
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jordanliu/portx/releases/download/v0.1.0/portx_0.1.0_darwin_arm64"
      sha256 "f2990e499bd37a623c82d3edf05d8f74020e205f841944b643b0cd96728e891e"
    else
      url "https://github.com/jordanliu/portx/releases/download/v0.1.0/portx_0.1.0_darwin_amd64"
      sha256 "616f0c3eef261a817675f7f8088839bd4a47c76b433e9ea55aba0b886f14aa4e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/jordanliu/portx/releases/download/v0.1.0/portx_0.1.0_linux_arm64"
      sha256 "9f3b93bdd5c75cdeda97feb168728cb7b50cc9dfffddaae649d3e68da87f5348"
    else
      url "https://github.com/jordanliu/portx/releases/download/v0.1.0/portx_0.1.0_linux_amd64"
      sha256 "6f5bc638fb8e85be302555e3a265aa801f5523f51d2d0a3dffaf9d9094b1685e"
    end
  end

  depends_on "cloudflared"

  def install
    bin.install Dir["portx_*"].first => "portx"
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
