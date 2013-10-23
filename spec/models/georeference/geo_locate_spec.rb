require 'spec_helper'

describe Georeference::GeoLocate do

  let(:geo_locate) { Georeference::GeoLocate.new }
  let(:request_params) {
    {country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}
  }
  let(:set_request) {
    geo_locate.request = request_params
  }

  context 'methods' do
    specify '.make_request builds a request string' do
      set_request
      expect(geo_locate.make_request).to be_true
      expect(geo_locate.read_attribute(:api_request)).to eq('country=usa&state=illinois&county=&locality=champaign&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json')

    end

    specify '.locate populates @response' do
      set_request
      geo_locate.locate
      expect(geo_locate.response).not_to be_nil

    end

    specify '#make_geographic_item populates #geographic_item when @response contains a result' do
      set_request
      geo_locate.locate
      geo_locate.make_geographic_item
      expect(geo_locate.geographic_item).not_to be_nil

    end

    specify '#make_error_geographic_item populates #error_geographic_item when @response contains a result' do
      set_request
      geo_locate.locate
      geo_locate.make_error_geographic_item
      expect(geo_locate.error_geographic_item).not_to be_nil
      expect(geo_locate.error_radius).to eq 7338

    end

    specify '.build wraps the whole process' do
      set_request {
        geo_locate.build
        expect(geo_locate.valid?).to be_true
      }
    end

  end

  context 'on new() with a valid request.' do

    context 'before .save' do

      specify '.build successfully completes' do
        g = Georeference::GeoLocate.new(request: request_params)
        expect(g.api_request).to eq 'country=usa&state=illinois&county=&locality=champaign&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json'
        expect(g.geographic_item.id).to be_nil
        expect(g.error_geographic_item.id).to be_nil
        expect(g.error_radius).to eq 7338.0
      end
    end

    context 'after .save' do
      specify '.save successfully completes' do
        g = Georeference::GeoLocate.new(request: request_params)
        g.save
        expect(g.error_geographic_item.object.contains?(g.geographic_item.object)).to be_true
      end
    end
  end

  context 'on invocation of new() with an invalid request' do
    specify 'errors are added to api_request' do
      set_request
      geo_locate.request['state'] = nil
      geo_locate.build
      expect(geo_locate.errors[:api_request]).to eq ['requested parameters returned no results']

    end
  end
end
