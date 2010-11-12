
module Papermill

  class ResponseParser
    def self.parse(status, headers, response)
      parsed_response = { :payload => {:headers => headers, :status => status} }
      Papermill::Storage.store << parsed_response
    end
  end

end
