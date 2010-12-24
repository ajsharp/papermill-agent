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

  describe '#log_error' do
    let(:logger) { Logger.new($stdout) }
    let(:exception) { mock('Exception', :message => 'msg', :backtrace => ['...']) }

    it 'records the message and the backtrace of the exception' do
      logger.should_receive(:error)
      exception.should_receive(:message)
      exception.should_receive(:backtrace)

      logger.log_exception(exception)
    end
  end
end
