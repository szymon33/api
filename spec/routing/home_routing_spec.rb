require 'spec_helper'

describe 'home route', type: :routing do
  subject { api_get '/' }

  it { should be_routable }
  it { should route_to(controller: 'api/heartbeat', action: 'status') }
end
