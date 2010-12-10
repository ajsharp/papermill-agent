require 'spec_helper'

module Papermill

  describe 'adding an item to the local data storage' do
    it 'acts like an array' do
      Storage.store.should respond_to(:<<)
    end

    it 'stores data' do
      Storage.store << 'some data'
      Storage.store.should include 'some data'
    end
  end

  describe 'the store' do
    it 'wraps the singleton instance' do
      Storage.store == Storage.instance
    end
  end

  describe 'determine the number of records stored' do
    before do
      Storage.store << 'record 1'
      Storage.store << 'record 2'
    end

    it 'should be 2' do
      Storage.size.should == 2
    end
  end

  describe 'emptying the cache' do
    before { Storage.clear }

    it 'clears out the storage' do
      Storage.store << 'stuff'
      Storage.store.should == ['stuff']

      Storage.clear
      Storage.store.should == []
    end
  end

end
