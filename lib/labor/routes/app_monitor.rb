require "sinatra/base"
require_relative '../deploy_service'
require_relative '../config'
require_relative '../models/application'
require_relative '../models/launch_info'
require_relative '../models/load_duration_pair'
require_relative '../models/operation_system'

module Labor
  class App < Sinatra::Base
    post '/app/monitor/launch' do 
      hash = body_params
      launch = hash['launch']

      ActiveRecord::Base.transaction do
        pairs = launch['load'].map do |name, duration|
          LoadDurationPair.create!(name: name, duration: duration)
        end
        info = LaunchInfo.create!(
          will_to_did: launch['will_to_did'], 
          start_to_did: launch['start_to_did'],
          load_total: launch['load_total'],
          load_duration_pairs: pairs
        )

        app = Application.find_or_initialize_by(hash['app'])
        app.launch_infos << info
        app.save!

        os = OperationSystem.find_or_initialize_by(hash['os'])
        os.launch_infos << info
        os.save!
      end

      labor_response 
    end

  end
end