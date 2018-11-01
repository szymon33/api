require 'spec_helper'

describe 'home route', type: :routing do
  subject { api_get '' }

  it { is_expected.to be_routable }
  it { is_expected.to route_to(format: 'json', controller: 'api/v1/heartbeat', action: 'status') }
end
