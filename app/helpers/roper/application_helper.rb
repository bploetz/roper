module Roper
  module ApplicationHelper

    # Creates an hash to be used as an error JSON response
    # https://tools.ietf.org/html/rfc6749#section-5.2
    def create_error(error, error_description=nil, error_uri=nil, state=nil)
      error = {:error => error}
      error[:error_description] = error_description if error_description
      error[:error_uri] = error_uri if error_uri
      error[:state] = state if state
      error
    end
  end
end
