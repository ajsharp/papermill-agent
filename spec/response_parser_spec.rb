require 'spec_helper'

module Papermill

  describe '.parse' do
    before do
      ResponseAdapters::Base.stub(:new).and_return(mock('object', :parse => nil))
    end
    context 'in a normal rack app' do
      it 'uses the base adapter' do
        ResponseAdapters::Base.should_receive(:new).and_return(mock('object', :parse => nil))
        ResponseParser.parse(200, {}, [], {})
      end
    end

    context 'in a rails app' do
      class Rails
      end

      it 'uses the rails adapter' do
        ResponseAdapters::Rails.should_receive(:new).and_return(mock('object', :parse => nil))
        ResponseParser.parse(200, {}, [], {})
      end
    end
  end

end
