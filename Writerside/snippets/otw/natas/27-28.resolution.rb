# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'cgi'
require 'base64'

# Creds
init = 27
username = "natas#{init + 1}"
password = File.readlines('../../../etc/otw/natas.pass')[init].strip

# Handles the requests for this level
class RequestHandler
  attr_reader :urlparam

  def initialize(username, password)
    @uri = URI("http://#{username}.natas.labs.overthewire.org/")
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @username = username
    @password = password
  end

  def doit(query)
    response = post(query)

    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      @urlparam = get_urlparam(response)
      loc = response['location']
      uri = "/#{loc}"
      get(uri)
    end
  end

  def post(query)
    request = Net::HTTP::Post.new(@uri)
    request.basic_auth(@username, @password)
    payload = { 'query' => query }
    request.set_form_data(payload)
    @http.request(request)
  end

  def get(uri)
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(@username, @password)
    @http.request(request)
  end

  def get_urlparam(response)
    urlencoded = response['location'].split('query=')[1]
    b64 = CGI.unescape(urlencoded)
    bytes = Base64.decode64(b64)
    bytes.unpack1('H*')
  end

  def get_with_arg(arg)
    uri = URI(@uri.to_s + "search.php/?query=#{arg}")
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(@username, @password)
    @http.request(request)
  end
end

handler = RequestHandler.new(username, password)

chars_uri = URI('https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Fuzzing/special-chars.txt')
special_chars = Net::HTTP.get(chars_uri).split("\n")
all_chars = ('A'..'Z').to_a + ('a'..'z').to_a + special_chars

# Special characters query test
special_chars.each do |c|
  puts "Char #{c}"
  puts handler.get_with_arg(c).body
end

# Multi length query test
(1..5).each do |n|
  handler.doit('a' * n)
  puts "[#{n}]\t\t#{handler.urlparam}"
end

# Finding block size
prevlen = -1
counter = 0
(1..80).each do |n|
  puts "LENGTH: #{n}"
  handler.doit('a' * n)
  len = handler.urlparam.length
  if len != prevlen
    puts "NEW LENGTH AFTER #{counter}" unless prevlen == -1
    prevlen = len
    counter = 0
  end
  counter += 1
end

# Block size proof
candidate_size = 16
handler.doit('A' * 12)
puts handler.urlparam.length    # n block size
handler.doit('A' * 13)
puts handler.urlparam.length    # n+1 block size
handler.doit('A' * (13 + candidate_size))
puts handler.urlparam.length    # n+2 block size
handler.doit('A' * (13 + candidate_size + candidate_size))
puts handler.urlparam.length    # n+3 block size

# Hex inspection
[13, 29, 45, 61].each do |n|
  handler.doit('A' * n)
  b64 = handler.urlparam
  puts b64
end

# Don't decode b64
def get_urlparam(response)
  urlencoded = response['location'].split('query')[1]
  CGI.unescape(urlencoded)
end

# String ending tests
len9 = 'A' * 9
allchars.each do |ch|
  handler.doit(len9 + ch)
  puts "[#{ch}]\t#{handler.urlparam}"
end
