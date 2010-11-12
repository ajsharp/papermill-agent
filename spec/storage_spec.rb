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

end
