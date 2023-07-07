# frozen_string_literal: true

describe Consulkit::Client::Session, :vcr do
  before(:all) do
    @client = Consulkit.client

    @created_session_ids = []
  end

  describe 'session_create' do
    it 'creates a session' do
      session_id = @client.session_create

      expect(session_id).to_not be_nil

      @created_session_ids << session_id
    end

    it 'camel cases keyword arguments' do
      session_id = @client.session_create(lock_delay: '30s')

      expect(session_id).to_not be_nil

      @created_session_ids << session_id
    end
  end

  describe 'session_read' do
    it 'reads a session' do
      session = @client.session_read(@created_session_ids.first)

      expect(session['ID']).to eq(@created_session_ids.first)
    end
  end

  describe 'session_renew' do
    it 'renews a session' do
      session = @client.session_renew(@created_session_ids.first)

      expect(session['ID']).to eq(@created_session_ids.first)
    end
  end

  describe 'session_delete' do
    it 'deletes a session' do
      result = @created_session_ids.all? do |session_id|
        @client.session_delete(session_id)
      end

      expect(result).to be true
    end
  end
end
