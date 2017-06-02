require 'jenkins_api_client'

module AnacapaJenkinsAPI
  class Build
    attr_reader :job
    attr_reader :build_no

    def initialize(job, build_no)
      @job = job
      @build_no = build_no
      @details = nil
    end

    def details(force: true)
      if @detials.nil? || force
        @details = AnacapaJenkinsAPI.client.job.get_build_details(@job.job_name, @build_no)
      end
      @details
    end

    def artifacts
      details(force: true)["artifacts"]
    end

    # NOTE: this input is the artifact object from artifacts
    def download_artifact(artifact, base_url: nil)
      if base_url.nil?
        base_url = self.details(:force => false)["url"]
      end

      uri = URI.parse("#{base_url}/artifact/#{artifact["relativePath"]}")

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(
          AnacapaJenkinsAPI.credentials["username"],
          AnacapaJenkinsAPI.credentials["password"]
      )
      response = http.request(request)

      response.body
    end

    def wait_for_finish()
      details = nil
      loop do
        details = self.details(force: true)
        break if !details.key?("building") || !details["building"]
        sleep(1)
      end
    end
  end
end