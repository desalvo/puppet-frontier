#!/usr/bin/ruby
require 'facter'

version = Facter::Util::Resolution.exec("rpm -q frontier-squid --queryformat '[%{NAME} %{VERSION}-%{RELEASE}\n]'")

if (version != nil)
    Facter.add("#{version.split[0]}_majver".gsub('-','_')) do
        setcode do
              "#{version.split[1].split('.')[0]}"
        end
    end
end
