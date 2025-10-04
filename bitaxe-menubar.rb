class BitaxeMenubar < Formula
  desc "BitAxe MenuBar - Simple Bitaxe miner status bar app"
  homepage "https://github.com/jeppepeppe1/BitAxe-MenuBar"
  url "https://github.com/jeppepeppe1/BitAxe-MenuBar/archive/refs/heads/main.zip"
  version "1.0.0"
  sha256 "06a611aab0bfb5c77aca4c1c560d0203008afbac50322e44e0314a8b56138b84"

  depends_on "swift" => :build
  depends_on "terminal-notifier"

  def install
    system "swift", "build", "--configuration", "release", "--disable-sandbox"
    bin.install ".build/release/bitaxe-menubar"
    
    # Install resources
    resources_dir = prefix/"Resources"
    resources_dir.mkpath
    resources_dir.install "Sources/BitAxeMenuBar/Resources/bitaxe-logo-square.png"
    resources_dir.install "Sources/BitAxeMenuBar/Resources/bitaxe-logo.png"
    
    # Create configuration script
    (bin/"bitaxe-config").write <<~EOS
      #!/bin/bash
      if [ -z "$1" ]; then
        echo "Usage: bitaxe-config <IP_ADDRESS>"
        echo "Example: bitaxe-config 192.168.1.100"
        exit 1
      fi
      
      # Set the IP address in UserDefaults
      defaults write com.bitaxe.menubar BitAxeIP "$1"
      echo "BitAxe IP address set to: $1"
      echo "Restart bitaxe-menubar to apply changes."
    EOS
    chmod 0755, bin/"bitaxe-config"
  end

  def caveats
    <<~EOS
      BitAxe MenuBar has been installed!
      
      To run BitAxe MenuBar:
        bitaxe-menubar
      
      To configure your BitAxe IP address via CLI:
        bitaxe-config 192.168.1.100
      
      To run on startup, add to Login Items in System Preferences:
        1. Open System Preferences > Users & Groups
        2. Select your user > Login Items
        3. Click + and add bitaxe-menubar
      
      The app will use simulation mode by default. To connect to your actual BitAxe:
        1. Edit the source code to uncomment the real API section
        2. Rebuild with: swift build --configuration release
    EOS
  end

  test do
    # Test that the binary exists and is executable
    assert_predicate bin/"bitaxe-menubar", :exist?
    assert_predicate bin/"bitaxe-menubar", :executable?
  end
end
