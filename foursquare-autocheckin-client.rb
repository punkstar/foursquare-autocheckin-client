#!/usr/bin/env ruby

require 'nmap/parser'
require "net/http"
require "uri"
require 'optparse'

# Option handling

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: foursquare-autocheckin-client.rb [options]"

  opts.on('--url URL', "Ping endpoint") do |c|
    options[:ping_endpoint] = c
  end

  opts.on('--range RANGE', "IP range (will be passed directly to nmap)") do |c|
    options[:ip_ranges] = c
  end

  opts.on('--once', "Will scan once and quit") do |c|
    options[:once] = c
  end
end.parse!

if options[:ping_endpoint].nil? or options[:ip_ranges].nil?
  abort "Missing required parameters"
end

# Main Body

while true
  begin
    puts "Starting.."
    parser = Nmap::Parser.parsescan("sudo nmap", "-sP #{options[:ip_ranges]}")

    puts "Nmap args: #{parser.session.scan_args}"

    $mac_addresses = []

    parser.hosts('up').each do |host|
      ip  = host.addr
      mac = host.mac_addr

      if not ip.nil? and not mac.nil?
        ip.chomp!
        mac.chomp!

        puts "Found #{ip} / #{mac}"

        $mac_addresses << mac.upcase
      end
    end

    if not $mac_addresses.nil? && $mac_adddresses.length > 0
      mac_addresses_string = $mac_addresses.join ","

      ping_uri_string = options[:ping_endpoint] + "?mac_addresses=" + mac_addresses_string
      puts ping_uri_string
      ping_endpoint_uri = URI.parse ping_uri_string

      Net::HTTP.get_print(ping_endpoint_uri)
      puts ""
    else
      puts "No mac addresses found"
    end

    if options[:once]
      exit
    end
  rescue
    puts "An error occurred"
  end
end
