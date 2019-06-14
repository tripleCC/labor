require "sinatra/base"
require_relative '../deploy_service'
require_relative '../config'
require_relative '../models/app_info'
require_relative '../models/launch_info'
require_relative '../models/load_duration_pair'
require_relative '../models/os_info'
require_relative '../models/device'

module Labor
  class App < Sinatra::Base
    clean_options_post '/app/monitor/launch' do 
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

        app = AppInfo.find_or_initialize_by(hash['app'])
        app.launch_infos << info
        app.save!

        os = OsInfo.find_or_initialize_by(hash['os'])
        os.launch_infos << info
        os.save!

        device = Device.find_or_initialize_by(hash['device'])
        device.launch_infos << info
        device.save!
      end

      labor_response
    end

    clean_options_get '/app/monitor/launch' do 
      param :app_name, String, required: true
      param :os_name, String, required: true

      keys = [:app_name, :app_version, :os_name, :os_version, :device_name].map(&:to_s)
      querys = params.select { |key, value| keys.include?(key) }

      app_query = { name: querys['app_name'], version: querys['app_version'] }.delete_if { |_, v| v.nil? }
      os_query = { name: querys['os_name'], version: querys['os_version'] }.delete_if { |_, v| v.nil? }
      device_query = { simple_name: querys['device_name'] }.delete_if { |_, v| v.nil? }
      includes = [:app_info, :os_info, :load_duration_pairs, :device]
      infos = LaunchInfo.with_app(app_query).with_os(os_query).with_device(device_query).includes(includes).order(created_at: :desc)

      labor_response infos, {
        includes: includes
      }
    end
  end
end