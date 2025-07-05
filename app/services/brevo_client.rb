require 'net/http'
require 'json'
require 'uri'

class BrevoClient
    BASE_URL = 'https://api.brevo.com/v3'

  def initialize(api_key: ENV['BREVO_API_KEY'])
    @api_key = api_key
  end

   def create_contact(email:, first_name:, last_name:)
    puts "[BrevoClient] Creating contact #{email}"
    body = {
      email: email,
      attributes: {
        # Remplace par tes codes d'attributs Revo exacts :
        NOM:      first_name,
        PRENOM:   last_name
      },
      updateEnabled: false
    }
    response = request(:post, '/contacts', body)
    puts "[BrevoClient] Response code: #{response.code}"
    puts "[BrevoClient] Response body: #{response.body}"
    response
  end

  def create_company(name:, email:, phone: nil)
    body = {
      name:         name,
      email:        email,
      phone_number: phone
    }
    request(:post, '/companies', body)
  end

  private

  def request(method, path, body = {})
    uri  = URI(BASE_URL + path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req_class = Net::HTTP.const_get(method.to_s.capitalize)
    req       = req_class.new(uri)
    req['Content-Type'] = 'application/json'
    req['Accept']       = 'application/json'
    req['api-key']      = @api_key
    req.body            = body.to_json

    http.request(req)
  end
end
