require 'spec_helper'

shared_examples_for Api::Authorizable do
  it 'authorizes access only with valid API key' do
    api_key = create :api_key

    get :sync, api_key: api_key.value, format: :json

    expect(response.code).to eql('200')
  end

  context 'with invalid API key' do
    it 'returns 401' do
      get :sync, format: :json

      errors = JSON.parse(response.body, symbolize_names: true)[:errors]

      expect(response.code).to eql('401')
      expect(errors).to eql(['Invalid API Key'])
    end
  end
end
