# frozen_string_literal: true

describe Consulkit::Client::KV, :vcr do
  before do
    @client = Consulkit.client

    @key   = 'foo'
    @value = 'bar'
    @flags = 1234
  end

  describe 'kv_write' do
    it 'writes the key' do
      success = @client.kv_write(@key, @value)

      expect(success).to be true
    end

    it 'passes query params' do
      success = @client.kv_write(@key, @value, cas: 0)

      expect(success).to be false

      success = @client.kv_write(@key, @value, flags: @flags)

      expect(success).to be true
    end
  end

  describe 'kv_read!' do
    it 'reads the key that was written' do
      kv_entries = @client.kv_read!(@key)

      expect(kv_entries.size).to be 1

      kv_entry = kv_entries.first

      expect(kv_entry['Key']).to eq(@key)
      expect(kv_entry['Value']).to eq(@value)
      expect(kv_entry['Flags']).to eq(@flags)
    end

    it 'raises an error for a missing key' do
      expect do
        @client.kv_read!('non-existent')
      end.to raise_error(Consulkit::Error::NotFound)
    end

    it 'passes query params' do
      value = @client.kv_read!(@key, raw: true)

      expect(value).to eq(@value)
    end
  end

  describe 'kv_read' do
    it 'returns an empty array for a missing key' do
      kv_entries = @client.kv_read('non-existent')

      expect(kv_entries.size).to be 0
    end
  end

  describe 'kv_read_single' do
    it 'returns the key unwrapped' do
      kv_entry = @client.kv_read_single(@key)

      expect(kv_entry['Key']).to eq(@key)
      expect(kv_entry['Value']).to eq(@value)
      expect(kv_entry['Flags']).to eq(@flags)
    end
  end

  describe 'kv_decode_response_body' do
    it 'decodes kv entries' do
      kv_entries = [
        { 'Key' => 'foo1', 'Value' => 'YmFy', 'ModifyIndex' => 1234 }, # other keys elided
        { 'Key' => 'foo2', 'Value' => 'YmF6', 'ModifyIndex' => 1234 }, # other keys elided
        { 'Key' => 'foo3', 'Value' => nil, 'ModifyIndex' => 1234 },    # other keys elided
      ]

      decoded_kv_entries = @client.kv_decode_response_body(kv_entries)

      expected_kv_entries = [
        { 'Key' => 'foo1', 'Value' => 'bar', 'ModifyIndex' => 1234 }, # other keys elided
        { 'Key' => 'foo2', 'Value' => 'baz', 'ModifyIndex' => 1234 }, # other keys elided
        { 'Key' => 'foo3', 'Value' => nil, 'ModifyIndex' => 1234 },   # other keys elided
      ]

      expect(decoded_kv_entries).to eq(expected_kv_entries)
    end

    it 'leaves other responses unchanged' do
      string_body = 'foo'

      expect(@client.kv_decode_response_body(string_body)).to be string_body

      array_body = %w[foo bar]

      expect(@client.kv_decode_response_body(array_body)).to be array_body
    end
  end
end
