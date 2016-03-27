require 'spec_helper'

RSpec.describe Regrapher::Client do

  LINE_REGEX = /^\[regrapher\]\[(\d+)\](.*)$/

  let(:output_stream) { StringIO.new }

  let(:client) { Regrapher::Client.new(output_stream: output_stream) }

  let(:string) { output_stream.string }

  {
      gauge:     ['basket.value', 34.2],
      increment: ['users.count'],
      decrement: ['users.count'],
      count:     ['users.count', -55],
      event:     ['users.sign_up', { name: 'John', company: 'Acme Corp' }]
  }.each do |method, params|
    context "##{method}" do

      it 'has a "[regrapher][<length>]" prefix' do
        client.send method, *params
        expect(string).to match(LINE_REGEX)
        _, length, json = string.match(LINE_REGEX).to_a
        expect(json.length).to eq(length.to_i)
      end

      it '<length> equals the json length' do
        client.send method, *params
        _, length, json = string.match(LINE_REGEX).to_a
        expect(json.length).to eq(length.to_i)
      end
    end
  end
end