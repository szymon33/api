module API
  class HeartbeatController < ApplicationController
    skip_before_filter :authenticate, only: :status

    def status
      render json: { message: 'OK' }, status: 200
    end
  end
end
