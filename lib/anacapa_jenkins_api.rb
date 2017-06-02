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
  end

end
