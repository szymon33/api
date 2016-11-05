def json
  JSON.parse(response.body, symbolize_names: true)
end

def encode_credentials(username, password)
  ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
end

def api_get(path, *args)
  get "http://api.example.com#{path}", *args
end

def api_post(path, *args)
  post "http://api.example.com#{path}", *args
end

def api_put(path, *args)
  put "http://api.example.com#{path}", *args
end

def api_delete(path, *args)
  delete "http://api.example.com#{path}", *args
end
