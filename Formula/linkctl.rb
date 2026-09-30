class Linkctl < Formula
  desc "Insta360 Link camera control daemon — USB/UVC control without the Insta360 app"
  homepage "https://github.com/jfwoods/insta360link-controller"
  url "https://github.com/jfwoods/insta360link-controller/releases/download/v0.2.0/linkctl-daemon-0.2.0-macos-arm64.tar.gz"
  version "0.2.0"
  sha256 "f61224b55fc84099a1cc2d49b2449d5d05845d653b52afa6149c3fe31ce0035d"

  depends_on "libwebsockets"
  depends_on "cjson"
  depends_on "openssl@3"

  resource "linkctl" do
    url "https://github.com/jfwoods/insta360link-controller/releases/download/v0.2.0/linkctl-0.2.0-macos-arm64.tar.gz"
    sha256 "285658ef170856c2c1a4bdc4a4d450cb41d2f029faeb66b7e998a5e72d970021"
  end

  def install
    bin.install "linkctl-daemon"
    resource("linkctl").stage { bin.install "linkctl" }

    lws = Formula["libwebsockets"]
    lws_lib = lws.opt_lib
    # Binary was built against libwebsockets.21; current Homebrew ships .22.
    # Remap the dylib reference so the binary loads from the installed version.
    system "install_name_tool", "-change",
      "#{lws_lib}/libwebsockets.21.dylib",
      "#{lws_lib}/libwebsockets.22.dylib",
      bin/"linkctl-daemon"
  end

  service do
    run opt_bin/"linkctl-daemon"
    keep_alive true
    log_path var/"log/linkctl-daemon.log"
    error_log_path var/"log/linkctl-daemon.log"
  end

  test do
    assert_predicate bin/"linkctl-daemon", :exist?
    assert_predicate bin/"linkctl-daemon", :executable?
    assert_predicate bin/"linkctl", :exist?
    assert_predicate bin/"linkctl", :executable?
  end
end
