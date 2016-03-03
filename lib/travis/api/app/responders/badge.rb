module Travis::Api::App::Responders
  class Badge < Image
    def format
      'svg'
    end

    instrument_method
    def apply
      set_headers
      if params.has_key?('streak')

        last_failing_build = Travis::API::V3::Models::Build.where(:repository_id => resource.id, :branch => resource.default_branch, :state => ['failed', 'canceled', 'errored'], :event_type => ['push', 'cron']).order("id DESC").select(:id).first
        fail_id = (last_failing_build != nil) ? last_failing_build.id : 0
        first_build_of_streak = Travis::API::V3::Models::Build.where(:repository_id => resource.id, :branch => resource.default_branch, :state => 'passed', :event_type => ['push', 'cron']).where("id > ?", fail_id).order("id ASC").select(:created_at).first
        streak = first_build_of_streak ? (((Time.now - first_build_of_streak.created_at)/(60*60*24)).floor) : 0

        color = streak > 0 ? '#4c1' : '#e05d44'
        add_width = streak.to_s.length * 6
        days = 'days'
        if streak == 1
          days = 'day'
          add_width -= 6
        end

        [200, {'Content-Type' => content_type, 'Last-Modified' => last_modified ? last_modified : resource.created_at.rfc2822},
          ['<?xml version="1.0" encoding="UTF-8"?>
            <svg xmlns="http://www.w3.org/2000/svg" width="' + (78 + add_width).to_s + '" height="20">
              <linearGradient id="a" x2="0" y2="100%">
                <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
                <stop offset="1" stop-opacity=".1"/>
              </linearGradient>
              <rect rx="3" width="' + (78 + add_width).to_s + '" height="20" fill="#555"/>
              <rect rx="3" x="38" width="' + (41 + add_width).to_s + '" height="20" fill="' + color + '"/>
              <path fill="' + color + '" d="M38 0h4v20h-4z"/>
              <rect rx="3" width="' + (78 + add_width).to_s + '" height="20" fill="url(#a)"/>
              <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
                <text x="19.5" y="15" fill="#010101" fill-opacity=".3">streak</text>
                <text x="19.5" y="14">streak</text>
                <text x="' + (57.5 + add_width / 2).to_s + '" y="15" fill="#010101" fill-opacity=".3">' + streak.to_s + ' ' + days + '</text>
                <text x="' + (57.5 + add_width / 2).to_s + '" y="14">' + streak.to_s + ' ' + days + '</text>
              </g>
            </svg>
          ']
        ]
      else
        send_file(filename, type: :svg, last_modified: last_modified)
      end
    end

    def content_type
      "image/svg+xml"
    end

    def filename
      "#{root}/public/images/result/#{result}.svg"
    end
  end
end
