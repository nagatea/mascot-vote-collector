require 'json'

CLIENT_ID = ENV['client_id']
CLIENT_SECRET = ENV['client_secret']
REFRESH_TOKEN = ENV['refresh_token']

class CreateConfig
  def initialize
    hash = { "client_id" => CLIENT_ID, "client_secret" => CLIENT_SECRET, "scope" => ["https://www.googleapis.com/auth/drive", "https://spreadsheets.google.com/feeds/"], "refresh_token" => REFRESH_TOKEN}
    @json_str = JSON.pretty_generate(hash)
  end

  def save_json(file_path)
    File.open(file_path, "w") do |file|
        file.write(@json_str)
    end
  end

  def delete_json(file_path)
    File.delete(file_path) if FileTest.exist?(file_path)
  end
end

