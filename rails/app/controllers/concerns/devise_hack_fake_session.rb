module DeviseHackFakeSession
  extend ActiveSupport::Concern

  class FakeSession < Hash
    def enabled?
      false
    end

    def destroy
    end
  end

  include do
    before_action :set_fake_session

    private

      def set_fake_session
        if Rails.configuration.respond_to?(:api_only) && Rails.configuration.api_only
          request.env["rack.session"] ||= ::DeviseHackFakeSession::FakeSession.new
        end
      end
  end

end