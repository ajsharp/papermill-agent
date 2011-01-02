require 'spec_helper'

module Papermill
  describe 'initializing the Base parser' do
    context 'with no environment' do
      let(:base) { ResponseAdapters::Base.new(200, {}, lambda {}) }

      it 'sets it to an empty hash' do
        base.env.should == {}
      end
    end
  end
end
