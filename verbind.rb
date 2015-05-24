#!/usr/bin/env ruby
# encoding: utf-8
#
# verbind.rb - (case-study) retrieve the version of bind by 
# executing a simple dns query request following the rfc standard.
#
# RFC-1035 - domain names - implementation and specification
# - http://tools.ietf.org/html/rfc1035
#
# Federico Fazzi <eurialo@deftcode.ninja>
# (c) 2015 - MIT License.
#

['socket', 'timeout'].each(&method(:require))

# Socket timeout.
TIMEOUT = 5

# Colors.
RST = "\e[0m"
GB  = "\e[1;32m"
RB  = "\e[1;31m"

# Execute the DNS query.
def _dns_query(host)

    # RFC 4.1.1 - HEADER SECTION FORMAT
    # -------------------------------------------------
    #                                 1  1  1  1  1  1
    #   0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |                      ID                       |
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |                    QDCOUNT                    |
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |                    ANCOUNT                    |
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |                    NSCOUNT                    |
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |                    ARCOUNT                    |
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

    # TRANSACTION ID: A 16-bit field identifying a specific 
    # DNS transaction. The transaction ID is created by the 
    # message originator and is copied by the responder into 
    # its response message. Using the transaction ID, the 
    # DNS client can match responses to its requests.

    # ID: A 16-bit identifier assigned by the program that 
    # generates any kind of query.
    payload = "\xC0\xDE"

    # FLAGS: A 16-bit field containing various service flags 
    # that are communicated between the DNS client and the 
    # DNS server.

    # OPCODE: (0: standard query) A 4-bit field that 
    # specifies kind of query in this message.
    # QR, OPCODE, AA, TC, RD, RA, Z, RCODE
    payload += "\x00\x00"
    
    # QDCOUNT: (question entries) an unsigned 16-bit integer
    # specifying the number of entries in the question section.
    payload += "\x00\x01"
    # ANCOUNT: (answer records) an unsigned 16-bit integer 
    # specifying the number of resource records in the answer 
    # section.
    payload += "\x00\x00"
    # NSCOUNT: (authority records) an unsigned 16-bit integer 
    # specifying the number of name server resource records in 
    # the authority records section.
    payload += "\x00\x00"
    # ARCOUNT: (additional records) an unsigned 16-bit integer 
    # specifying the number of resource records in the additional 
    # records section.
    payload += "\x00\x00"

    # RFC 4.1.2. QUESTION SECTION FORMAT
    # -------------------------------------------------
    #                                 1  1  1  1  1  1
    #   0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |                                               |
    # /                     QNAME                     /
    # /                                               /
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |                     QTYPE                     |
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # |                     QCLASS                    |
    # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

    # QNAME: versionbind, variable length.
    # the length of 'version' is 7-byte.
    payload += "\x07"
    # the 'version' in hex.
    payload += "\x76\x65\x72\x73\x69\x6f\x6e"
    # the length of 'bind' is 4-byte.
    payload += "\x04"
    # the 'bind' in hex.
    payload += "\x62\x69\x6e\x64"
    # terminate the qname with zero-length octet (16-bit)
    payload += "\x00\x00"

    # QTYPE:  (10: NULL, null resource record) 16-bit unsigned.
    payload += "\x10\x00"
    # QCLASS: (3: CH - chaos) 16-bit unsigned.
    payload += "\x03"

    puts "#{GB}>#{RST} Requesting for version.bind to address: #{GB}#{host}#{RST}"

    begin
        socket = UDPSocket.new
        socket.connect(host, 0x35)

        Timeout.timeout(TIMEOUT) {
            # A sendto() udp payload 
            # to host on port 53.
            if socket.send(payload, 0, host, 0x35)
                bind_version = ''
                ret = socket.recv(1024)
                socket.close

                # Parse the bind version, skip the first 24 bytes 
                # that identify your version bind string and other 
                #`unneeded hex characters from the response.
                for i in 0..ret.length - 1
                    if ret[i] =~ /^[[:graph:]]$/ and i > 24
                        bind_version += ret[i].chr
                    end
                end

                return puts "#{GB}+#{RST} Bind version found: #{GB}#{bind_version}#{RST}"
            end
        }
    rescue SocketError, Errno::ECONNREFUSED
        return puts "#{RB}- error:#{RST} connection refused (bad address?)."
    rescue Timeout::Error
        return puts "#{RB}- error:#{RST} connection timed out."
    end
end

# Check for valid argument.
if ARGV.first.nil?
    abort("usage: ruby bind-version.rb example.org")
end

_dns_query(ARGV.first)

