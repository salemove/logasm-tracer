
require "spec_helper"

RSpec.describe Lenjador::Tracer::Span do
  let(:span) { described_class.new(context, operation_name, logger, start_time: start_time) }

  let(:context) do
    Lenjador::Tracer::SpanContext.new(trace_id: trace_id, parent_id: parent_id, span_id: span_id)
  end
  let(:trace_id) { 'trace-id' }
  let(:parent_id) { 'parent-id' }
  let(:span_id) { 'span-id' }
  let(:operation_name) { 'operation-name' }
  let(:logger) { spy('logger') }
  let(:duration_in_seconds) { 10.0 }

  let(:start_time) { Time.local(2017, 5, 1, 22, 10, 00) }
  let(:end_time) { start_time + duration_in_seconds }

  describe '#operation_name=' do
    it 'changes operation name' do
      new_name = 'new-operation-name'
      span.operation_name = new_name
      span.finish
      expect(logger).to have_received(:info).with("Span [#{new_name}] finished", anything)
    end
  end

  describe '#finish' do
    it 'logs out span information' do
      span.finish(end_time: end_time)
      expect(logger).to have_received(:info).with("Span [#{operation_name}] finished",
        trace: {
          id: trace_id,
          parent_id: parent_id,
          span_id: span_id,
          operation_name: operation_name,
          execution_time: duration_in_seconds
        }
      )
    end

    context 'when tag set through #set_tag' do
      let(:tag_name) { 'tag-name' }
      let(:tag_value) { 'tag-value' }

      it 'includes tags in the span information' do
        span.set_tag(tag_name, tag_value)
        span.finish(end_time: end_time)
        expect(logger).to have_received(:info).with("Span [#{operation_name}] finished",
          trace: a_hash_including(tag_name => tag_value)
        )
      end
    end
  end
end
