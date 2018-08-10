# Fact: squidpartsize
#
# Purpose: Report the size of the volume that cache_dir resides on.
# A yaml file should have been created by puppet so it may take
# two runs of puppet for this fact to become active.

require 'yaml'
Facter.add(:squidcachepartsize) do
  confine :kernel => 'Linux'
  setcode do
    if File.exist?('/etc/squid/squidfacts.yaml')
      directory = YAML.load(File.open('/etc/squid/squidfacts.yaml'))['squid_cache_dir']
      Facter::Util::Resolution.exec("/bin/df -m -P #{directory}").split("\n").last.split(%r{\s+})[1]
    end
  end
end
