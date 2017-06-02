require 'anacapa_jenkins_api/version'
require 'anacapa_jenkins_api/build'
require 'anacapa_jenkins_api/job'
require 'anacapa_jenkins_api/assignment'
require 'jenkins_api_client'

module AnacapaJenkinsAPI
  SETUP_ASSIGNMENT = 'AnacapaGrader-setupAssignment'

  def assignment_job(provider, org, lab)
    "AnacapaGrader #{provider} #{org} assignment-#{lab}"
  end

  def grader_job(provider, org, lab)
    "AnacapaGrader #{provider} #{org} grader-#{lab}"
  end

  class << self
    attr_reader :client, :credentials
    def configure(credentials)
      @credentials = credentials
      @client = JenkinsApi::Client.new(@credentials.merge({:log_level => 4}))
    end
  end

  _setup_assignment_job = Job.new(AnacapaJenkinsAPI::SETUP_ASSIGNMENT)
  def setup_assignment_job
    _setup_assignment_job
  end
end
