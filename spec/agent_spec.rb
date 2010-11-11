require 'spec_helper'

describe Papermill::Agent, 'intializing the agent' do
  context 'when a new process is started' do
    context 'when an agent process does not already exist' do
      it 'should create a new agent process' do
        Papermill::Agent.instance.should be_instance_of Papermill::Agent
      end
    end

    context 'when an agent process already exists' do
      it 'should only allow one agent instance to exist' do
        Papermill::Agent.instance.should eql Papermill::Agent.instance
      end
    end
  end

  context 'when attempting to initialize the agent directly' do
    it 'raises a NoMethodError for attempting to access a private method' do
      lambda {
        Papermill::Agent.initialize
      }.should raise_error(NoMethodError, /private method `initialize' called/)
    end
  end

end

describe Papermill::Agent, '#start' do
  it 'attempts to contact the server' do
    Papermill::Agent.instance.should_receive(:connect!)
    Papermill::Agent.instance.start
  end
end

describe 'connecting to the papermill server' do
  context 'when we should connect to a remote'
end

describe 'determining if we should connect to the remote papermill server' do
end
