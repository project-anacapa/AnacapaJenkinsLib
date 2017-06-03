require 'anacapa_jenkins_api/version'
require 'anacapa_jenkins_api/build'
require 'anacapa_jenkins_api/jenkins_job'
require 'anacapa_jenkins_api/assignment'
require 'jenkins_api_client'

module AnacapaJenkinsAPI
  SETUP_ASSIGNMENT = 'AnacapaGrader-setupAssignment'

  class << self
    attr_reader :client, :credentials, :setup_assignment_job

    def configure(credentials)
      @credentials = credentials
      @client = JenkinsApi::Client.new(@credentials.merge({:log_level => 4}))
      @setup_assignment_job = JenkinsJob.new(AnacapaJenkinsAPI::SETUP_ASSIGNMENT)
    end

    def make_request(url)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(
          AnacapaJenkinsAPI.credentials["username"],
          AnacapaJenkinsAPI.credentials["password"]
      )

      http.request(request)
    end
  end

end
