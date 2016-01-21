module Travis::API::V3
  class Services::Crons::Start < Service
    #params :id

    def run!
      Models::Cron::start_all
    end
  end
end
