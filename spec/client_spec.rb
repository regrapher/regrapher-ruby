require 'spec_helper'

RSpec.describe Regrapher::Client do

  LINE_REGEX = /^\[regrapher\]\[(\d+)\](.*)$/

  let(:output_stream) { StringIO.new }

  let(:client) { Regrapher::Client.new(output_stream: output_stream) }

  let(:string) { output_stream.string }

  let(:parser) { Regrapher::Parser.new }

  let(:now) { Time.now }

  metric_type_to_params = {
      gauge:     ['basket.value', 34.2],
      increment: ['users.count'],
      decrement: ['users.count'],
      count:     ['users.count', -55],
      event:     ['users.sign_up', { name: 'John', company: 'Acme Corp' }]
  }

  tag_sets = [nil, [], ['tag.x'], %w(tag1 tag2 tag3 tag4.subtag)]

  metric_type_to_params.map { |m, p| tag_sets.map { |t| [m, p, t] } }.flatten(1).each do |method, params, tags|
    context "##{method}" do

      before do
        Timecop.freeze(now) do
          client.send method, *(params + (tags ? [tags: tags] : []))
        end
      end

      it 'has a "[regrapher][<length>]" prefix' do
        expect(string).to match(LINE_REGEX)
      end

      it '<length> equals the json length' do
        _, length, json = string.match(LINE_REGEX).to_a
        expect(json.length).to eq(length.to_i)
      end

      context 'parsed metric object' do

        let(:obj) { parser.parse(string) }

        it 'is not nil' do
          expect(obj).to_not be_nil
        end

        it 'has the correct value' do
          expected_value = case method
                             when :increment
                               1
                             when :decrement
                               -1
                             else
                               params[1]
                           end
          expect(obj[:value]).to eq(expected_value)
        end

        it 'has the correct tags' do
          expect(obj[:tags]).to match tags
        end

        it 'has the correct timestamp' do
          expect(obj[:ts]).to eq(now.to_i)
        end

        it 'has the correct name' do
          expect(obj[:name]).to eq(params[0])
        end

        it 'has an id' do
          expect(obj[:id]).to_not be_nil
        end
      end
    end
  end
end