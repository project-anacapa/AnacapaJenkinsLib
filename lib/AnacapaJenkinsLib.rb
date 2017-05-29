require 'AnacapaJenkinsLib/version'
require 'jenkins_api_client'

module AnacapaJenkinsLib
  def self.configure(credentials)
    @credentials = credentials
    @client = JenkinsApi::Client.new(@credentials.merge({:log_level => 4}))
  end

  def self.client
    return @client
  end

  def self.credentials
    return @credentials
  end

  class Build
    attr_reader :job
    attr_reader :buildNo

    def initialize(job, buildNo)
      @job = job
      @buildNo = buildNo
      @details = nil
    end

    def details(force: true)
      if @detials.nil? || force then
        @details = AnacapaJenkinsLib::client.job.get_build_details(@job.jobName, @buildNo)
      end
      return @details
    end

    def artifacts
      return details(force: true) ["artifacts"]
    end

    def downloadArtifact(artifact, baseUrl: nil) # NOTE: this input is the artifact object from artifacts
      if baseUrl.nil? then
        baseUrl = self.details(:force => false)["url"]
      end

      uri = URI.parse("#{baseUrl}/artifact/#{artifact["relativePath"]}")

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(AnacapaJenkinsLib::credentials["username"], AnacapaJenkinsLib::credentials["password"])
      response = http.request(request)

      return response.body
    end

    def waitForBuildToFinish()
      details = nil
      loop do
        details = self.details(force: true)
        break if !details.key?("building") || !details["building"]
        sleep(1)
      end
    end
  end

  class Job
    attr_reader :jobName
    def initialize(jobName)
      @jobName = jobName
    end

    def rebuild(env=nil) # NOTE: this can throw connection exceptions etc.
      buildNo = AnacapaJenkinsLib::client.job.build(@jobName, env || {}, {
          "build_start_timeout" => 30,
          "poll_interval" => 1
        })
      return getBuild(buildNo)
    end

    def currentBuild
      result = AnacapaJenkinsLib::client.job.get_current_build_number(@jobName)
      return nil if result < 1
      return getBuild(result)
    end

    def getBuild(buildNo)
      return Build.new(self, buildNo)
    end

    def exists?
      return AnacapaJenkinsLib::client.job.exists?(@jobName)
    end

    def destroy!
      return AnacapaJenkinsLib::client.job.delete(@jobName)
    end
  end

  JobSetupAssignment = Job.new('AnacapaGrader-setupAssignment')

  class Assignment
    attr_reader :gitProviderDomain
    attr_reader :courseOrg
    attr_reader :credentials_id
    attr_reader :credentialsId
    attr_reader :labName

    attr_reader :jobGrader
    attr_reader :jobInstructor

    def initialize(gitProviderDomain:, courseOrg:, credentialsId:, labName:)
      @gitProviderDomain = gitProviderDomain
      @courseOrg = courseOrg
      @credentialsId = credentialsId
      @labName = labName

      @jobInstructor = Job.new("AnacapaGrader #{@gitProviderDomain} #{@courseOrg} assignment-#{@labName}")
      @jobGrader = Job.new("AnacapaGrader #{@gitProviderDomain} #{@courseOrg} grader-#{@labName}")
    end

    def checkJenkinsState
      # checks that the projects exist on jenkins
      if !@jobInstructor.exists? || !@jobGrader.exists? then
        # trigger a rebuild of both the instructor and grader jobs...
        begin
          @jobInstructor.destroy!
        rescue

        end
        begin
          @jobGrader.destroy!
        rescue
        end

        setupBuild = nil
        setupBuild = JobSetupAssignment.rebuild({
            "git_provider_domain" => @gitProviderDomain,
            "course_org" => @courseOrg,
            "credentials_id" => @credentialsId,
            "lab_name" => @labName
          })

        setupBuild.waitForBuildToFinish()

        details = setupBuild.details

        raise "An error was encountered while running the grader jobs. Status: #{details["result"]}" unless details["result"] == "SUCCESS"
        raise "Failed to create the expected jobs." unless !@jobInstructor.exists? || !@jobGrader.exists?
      end
    end
  end
end
