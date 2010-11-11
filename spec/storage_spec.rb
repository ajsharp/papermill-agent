require 'spec_helper'

module Papermill

  describe 'adding an item to the local data storage' do
    it 'acts like an array' do
      Storage.instance.should respond_to(:<<)
    end

    it 'stores data' do
      Storage.instance << 'some data'
      Storage.instance.should include 'some data'
    end
  end

end
