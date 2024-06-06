# frozen_string_literal: true

describe Consulkit::Client::Health, :vcr do
  before do
    @client  = Consulkit.client
    @service = 'consul'
  end

  describe 'health_list_service_instances' do
    it 'lists the instances' do
      instances = @client.health_list_service_instances(@service)

      expect(instances.length).to be 1

      first_instance = instances.first

      expect(first_instance.dig('Node', 'Node')).to eq('localhost')
      expect(first_instance.dig('Service', 'ID')).to eq('consul')
      expect(first_instance.dig('Checks', 0, 'CheckID')).to eq('serfHealth')
    end

    it 'passes query params' do
      instances = @client.health_list_service_instances(@service, filter: 'Checks.Status == "passing"')

      expect(instances.length).to be 1

      first_instance = instances.first

      expect(first_instance.dig('Node', 'Node')).to eq('localhost')
      expect(first_instance.dig('Service', 'ID')).to eq('consul')
      expect(first_instance.dig('Checks', 0, 'CheckID')).to eq('serfHealth')

      instances = @client.health_list_service_instances(@service, filter: 'Checks.Status != "passing"')

      expect(instances.length).to be 0
    end
  end
end
