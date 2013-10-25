require 'helper'

class ClientTest < MiniTest::Test
  include ExconHelper

  # Client.<resource> raises a NoMethodError when a method is invoked
  # without a matching resource.
  def test_invalid_resource
    client = Heroics::Client.new({})
    error = assert_raises NoMethodError do
      client.unknown
    end
    assert_match(
      /undefined method `unknown' for #<Heroics::Client:0x[0-9a-f]{14}>/,
      error.message)
  end

  # Client.<resource>.<link> finds the appropriate link and invokes it.
  def test_resource
    link = Heroics::Link.new('https://username:secret@example.com',
                             '/resource', :get)
    resource = Heroics::Resource.new({'link' => link})
    client = Heroics::Client.new({'resource' => resource})
    Excon.stub(method: :get) do |request|
      assert_equal('Basic dXNlcm5hbWU6c2VjcmV0',
                   request[:headers]['Authorization'])
      assert_equal('example.com', request[:host])
      assert_equal(443, request[:port])
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, body: 'Hello, world!'}
    end
    assert_equal('Hello, world!', client.resource.link)
  end
end