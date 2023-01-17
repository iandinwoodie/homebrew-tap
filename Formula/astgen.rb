class Astgen < Formula
  desc "Generate AST in json format for JS/TS"
  homepage "https://github.com/joernio/astgen"
  url "https://github.com/joernio/astgen/archive/refs/tags/v2.10.0.tar.gz"
  sha256 "ff299c1db8703f9c47192d314ed656440c2f070ed502dfafe07be7351ea05296"
  license "Apache-2.0"

  # The build uses vercel/pkg to package the node app into a binary. This
  # depends on vercel/pkg-fetch which tends to support only even-numbered node
  # releases. For future maintenance, the vercel/pkg-fetch Binary Compatibility
  # table should be consulted for the most recent supported node version:
  # https://github.com/vercel/pkg-fetch#binary-compatibility
  depends_on "node@18" => :build
  depends_on "yarn" => :build

  def install
    system "yarn", "install", "--target"

    target = if OS.mac?
      Hardware::CPU.intel? ? "astgen-macos-x64" : "astgen-macos-arm64"
    else
      "astgen-linux-x64"
    end

    bin.install target
  end

  test do
    target = if OS.mac?
      Hardware::CPU.intel? ? "astgen-macos-x64" : "astgen-macos-arm64"
    else
      "astgen-linux-x64"
    end

    (testpath/"main.js").write <<~EOS
      console.log("Hello, world!");
    EOS

    assert_match "Converted AST", shell_output("#{target} -t js -i . -o out")
    assert_match '"fullName": "main.js"', File.read("out/main.js.json")
    assert_match '"1":"Console"', File.read("out/main.js.typemap")
  end
end
