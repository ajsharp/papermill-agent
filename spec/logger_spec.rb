require 'spec_helper'

module Papermill
  describe 'the papermill logger' do
    it 'inherits from the ruby std lib logger' do
      ::Papermill::Logger.superclass.should == ::Logger
    end
  end
  
  describe 'instantiating the log file' do
    context 'when the log directory does not exist' do
      it 'should not raise a file system error' do
        lambda {
          Logger.new
        }.should_not raise_error(Errno::ENOENT)
      end
      
      it 'creates the log file' do
        Logger.new
        File.exists?('log/papermill.log').should be_true
      end
    end
  end
end
